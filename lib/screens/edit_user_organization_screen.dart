import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/edit_service.dart';
import '../services/location_service.dart';
import '../services/profile_service.dart';
import '../i18n/app_translations.dart';
import '../i18n/locale_provider.dart';
import '../storage/token_storage.dart';

class EditUserOrganizationScreen extends StatefulWidget {
  const EditUserOrganizationScreen({super.key});

  @override
  State<EditUserOrganizationScreen> createState() => _EditUserOrganizationScreenState();
}

class _EditUserOrganizationScreenState extends State<EditUserOrganizationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _editService = EditService();
  final _locationService = LocationService();
  final _profileService = ProfileService();
  final _picker = ImagePicker();

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _orgCodeController = TextEditingController();
  final _orgLegalNameController = TextEditingController();
  final _orgAbbreviatedNameController = TextEditingController();
  final _orgEmailController = TextEditingController();
  final _orgPhoneController = TextEditingController();
  final _orgWebsiteController = TextEditingController();
  final _orgAddressController = TextEditingController();
  final _orgGeolocationController = TextEditingController();

  Uint8List? _logoBytes;
  String? _existingLogo;
  bool _logoChanged = false;

  String _selectedLanguage = 'en';
  String _selectedTimezone = 'America/Caracas';

  bool _loading = true;
  bool _saving = false;
  int? _entityId;

  List<Map<String, dynamic>> _countries = [];
  Map<String, dynamic>? _selectedCountry;
  List<Map<String, dynamic>> _states = [];
  Map<String, dynamic>? _selectedState;
  List<Map<String, dynamic>> _localities = [];
  String? _selectedLocality;
  String _orgLocalityText = '';

  List<Map<String, dynamic>> _profiles = [];
  bool _profilesLoading = true;
  Set<int> _selectedProfileIds = <int>{};

  @override
  void initState() {
    super.initState();
    _selectedLanguage = localeProvider.currentLanguageCode;
    _selectedProfileIds = <int>{};
    _loadData();
  }

  List<DropdownMenuItem<String>> _buildTimezoneItems() {
    final list = <Map<String, String>>[
      {'value': 'America/Caracas', 'key': 'tz_America_Caracas'},
      {'value': 'America/New_York', 'key': 'tz_America_New_York'},
      {'value': 'America/Mexico_City', 'key': 'tz_America_Mexico_City'},
      {'value': 'America/Argentina/Buenos_Aires', 'key': 'tz_America_Argentina_Buenos_Aires'},
      {'value': 'America/Bogota', 'key': 'tz_America_Bogota'},
      {'value': 'America/Santiago', 'key': 'tz_America_Santiago'},
      {'value': 'America/Lima', 'key': 'tz_America_Lima'},
      {'value': 'Europe/Madrid', 'key': 'tz_Europe_Madrid'},
      {'value': 'Europe/Lisbon', 'key': 'tz_Europe_Lisbon'},
      {'value': 'UTC', 'key': 'tz_UTC'},
    ];
    return list.map((tz) {
      return DropdownMenuItem<String>(
        value: tz['value'] as String,
        child: Text(AppTranslations.of(tz['key'] as String)),
      );
    }).toList();
  }

  Future<void> _loadData() async {
    final entityId = await TokenStorage.getEntityId();
    if (entityId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppTranslations.of('error')}: No se encontró ID de organización')),
        );
        Navigator.pop(context);
      }
      return;
    }
    _entityId = entityId;

    try {
      final org = await _editService.getOrganization(entityId);
      final countries = await _locationService.getCountries();
      final allProfiles = await _profileService.getProfilesByTarget('O');

      if (mounted) {
        setState(() {
          _existingLogo = org['logo'] as String?;

          final userData = org['user'] as Map<String, dynamic>?;
          _emailController.text = userData?['email'] as String? ?? '';
          _usernameController.text = userData?['username'] as String? ?? '';
          _selectedLanguage = userData?['language'] as String? ?? 'en';
          _selectedTimezone = userData?['timezone'] as String? ?? 'America/Caracas';

          _orgCodeController.text = org['code'] as String? ?? '';
          _orgLegalNameController.text = org['name'] as String? ?? '';
          _orgAbbreviatedNameController.text = org['abbreviated_name'] as String? ?? '';
          _orgPhoneController.text = org['phone'] as String? ?? '';
          _orgWebsiteController.text = org['website'] as String? ?? '';
          _orgAddressController.text = org['address'] as String? ?? '';
          _orgGeolocationController.text = org['geolocation'] as String? ?? '';
          _orgLocalityText = org['locality'] as String? ?? '';

          _profiles = allProfiles;
          final existingProfiles = (userData?['profiles'] as List<dynamic>?)
              ?.map((p) => (p as Map<String, dynamic>)['id'] as int)
              .toSet() ?? <int>{};
          _selectedProfileIds = existingProfiles;
          _profilesLoading = false;

          _countries = countries;

          final stateData = org['state'] as Map<String, dynamic>?;
          if (stateData != null) {
            final countryData = stateData['country'] as Map<String, dynamic>?;
            final countryId = countryData?['id'] as int? ?? stateData['countryId'] as int?;
            final matchedCountry = countryId != null
                ? _countries.where((c) => c['id'] == countryId).firstOrNull
                : null;
            if (matchedCountry != null) {
              _selectedCountry = matchedCountry;
              _loadStates(matchedCountry['id'] as int).then((_) {
                final state = _states.where((s) => s['id'] == stateData['id']).firstOrNull;
                if (state != null) {
                  _selectedState = state;
                  _loadLocalities(state['id'] as int);
                }
              });
            }
          }

          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppTranslations.of('error')}: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _loadStates(int countryId) async {
    try {
      final states = await _locationService.getStatesByCountry(countryId);
      if (mounted) setState(() => _states = states);
    } catch (_) {
      if (mounted) setState(() => _states = []);
    }
  }

  Future<void> _loadLocalities(int stateId) async {
    try {
      final localities = await _locationService.getLocalitiesByState(stateId);
      if (mounted) setState(() => _localities = localities);
    } catch (_) {
      if (mounted) setState(() => _localities = []);
    }
  }

  Future<void> _pickLogo() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();
    setState(() {
      _logoBytes = bytes;
      _logoChanged = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_entityId == null) return;

    setState(() => _saving = true);

    try {
      await _editService.editOrganizationUser(
        userId: _entityId!,
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        language: _selectedLanguage,
        timezone: _selectedTimezone,
        code: _orgCodeController.text.trim(),
        name: _orgLegalNameController.text.trim(),
        abbreviated_name: _orgAbbreviatedNameController.text.trim().isEmpty
            ? null : _orgAbbreviatedNameController.text.trim(),
        phone: _orgPhoneController.text.trim().isEmpty ? null : _orgPhoneController.text.trim(),
        website: _orgWebsiteController.text.trim().isEmpty ? null : _orgWebsiteController.text.trim(),
        address: _orgAddressController.text.trim().isEmpty ? null : _orgAddressController.text.trim(),
        geolocation: _orgGeolocationController.text.trim().isEmpty ? null : _orgGeolocationController.text.trim(),
        locality: (_selectedLocality ?? _orgLocalityText).isEmpty ? null : (_selectedLocality ?? _orgLocalityText),
        stateId: _selectedState?['id'] as int?,
        logoBytes: _logoChanged ? _logoBytes : null,
        logoFilename: null,
        profileIds: _selectedProfileIds.toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.of('edit_success'))),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppTranslations.of('error')}: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppTranslations.of('change_password')),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppTranslations.of('current_password'),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? AppTranslations.of('enter_password') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppTranslations.of('new_password'),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return AppTranslations.of('enter_password');
                  if (v.length < 12) return AppTranslations.of('password_min');
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppTranslations.of('cancel'))),
          ElevatedButton(onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(ctx, true);
            }
          }, child: Text(AppTranslations.of('change_password'))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _editService.changePassword(
          currentPassword: currentController.text,
          newPassword: newController.text,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.of('password_changed'))),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppTranslations.of('error')}: $e')),
        );
      }
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppTranslations.of('delete_account')),
        content: Text(AppTranslations.of('delete_account_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppTranslations.of('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppTranslations.of('delete_account')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _editService.deleteAccount();
        await TokenStorage.deleteToken();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.of('account_deleted'))),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppTranslations.of('error')}: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _orgCodeController.dispose();
    _orgLegalNameController.dispose();
    _orgAbbreviatedNameController.dispose();
    _orgEmailController.dispose();
    _orgPhoneController.dispose();
    _orgWebsiteController.dispose();
    _orgAddressController.dispose();
    _orgGeolocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.of('edit'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _pickLogo,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 100,
                                backgroundColor: const Color(0xFF2A2A2A),
                                backgroundImage: _logoBytes != null
                                    ? MemoryImage(_logoBytes!)
                                    : (_existingLogo != null
                                        ? NetworkImage('http://localhost:3000/${_existingLogo!.replaceAll('\\', '/')}')
                                        : null),
                                child: _logoBytes == null && _existingLogo == null
                                    ? const Icon(Icons.business, size: 40)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                ),
                              ),
                              if (_logoBytes != null)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      _logoBytes = null;
                                      _logoChanged = true;
                                    }),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppTranslations.of('account_data'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usernameController,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: AppTranslations.of('username'),
                          prefixIcon: const Icon(Icons.person),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: AppTranslations.of('email'),
                          prefixIcon: const Icon(Icons.email),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return AppTranslations.of('enter_email');
                          if (!v.contains('@')) return AppTranslations.of('invalid_email');
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedLanguage,
                              decoration: InputDecoration(
                                labelText: AppTranslations.of('language_label'),
                                border: const OutlineInputBorder(),
                              ),
                              items: [
                                DropdownMenuItem(value: 'en', child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(2)),
                                      child: Image.network('https://flagcdn.com/32x24/us.png', width: 32, height: 24, fit: BoxFit.cover),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('English'),
                                  ],
                                )),
                                DropdownMenuItem(value: 'es', child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(2)),
                                      child: Image.network('https://flagcdn.com/32x24/es.png', width: 32, height: 24, fit: BoxFit.cover),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Español'),
                                  ],
                                )),
                                DropdownMenuItem(value: 'pt', child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(2)),
                                      child: Image.network('https://flagcdn.com/32x24/br.png', width: 32, height: 24, fit: BoxFit.cover),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Português'),
                                  ],
                                )),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedLanguage = v);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedTimezone,
                              decoration: InputDecoration(
                                labelText: AppTranslations.of('timezone_label'),
                                prefixIcon: const Icon(Icons.access_time),
                                border: const OutlineInputBorder(),
                              ),
                              items: _buildTimezoneItems(),
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedTimezone = v);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppTranslations.of('profiles'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _profilesLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ..._profiles.map((p) {
                                  final id = (p['id'] as num).toInt();
                                  return CheckboxListTile(
                                    value: _selectedProfileIds.contains(id),
                                    onChanged: (checked) {
                                      setState(() {
                                        if (checked == true) {
                                          _selectedProfileIds.add(id);
                                        } else {
                                          _selectedProfileIds.remove(id);
                                        }
                                      });
                                    },
                                    title: Text(p['name'] as String),
                                    controlAffinity: ListTileControlAffinity.leading,
                                    contentPadding: EdgeInsets.zero,
                                  );
                                }),
                                if (_selectedProfileIds.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      AppTranslations.of('select_profile'),
                                      style: const TextStyle(color: Colors.red, fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showChangePasswordDialog(),
                          icon: const Icon(Icons.lock),
                          label: Text(AppTranslations.of('change_password')),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppTranslations.of('org_data'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _orgCodeController,
                        decoration: InputDecoration(
                          labelText: AppTranslations.of('org_code'),
                          prefixIcon: const Icon(Icons.qr_code),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? AppTranslations.of('enter_code') : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _orgLegalNameController,
                        decoration: InputDecoration(
                          labelText: AppTranslations.of('legal_name'),
                          prefixIcon: const Icon(Icons.badge),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? AppTranslations.of('enter_legal_name') : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _orgAbbreviatedNameController,
                        decoration: InputDecoration(
                          labelText: AppTranslations.of('abbreviated_name'),
                          prefixIcon: const Icon(Icons.short_text),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _orgEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: AppTranslations.of('org_email'),
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _orgPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: AppTranslations.of('phone'),
                          prefixIcon: const Icon(Icons.phone),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _orgWebsiteController,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                          labelText: AppTranslations.of('website'),
                          prefixIcon: const Icon(Icons.language),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _orgAddressController,
                        decoration: InputDecoration(
                          labelText: AppTranslations.of('address'),
                          prefixIcon: const Icon(Icons.location_on),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _orgGeolocationController,
                        decoration: InputDecoration(
                          labelText: AppTranslations.of('geolocation'),
                          prefixIcon: const Icon(Icons.map),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppTranslations.of('location'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Map<String, dynamic>>(
                        value: _selectedCountry,
                        decoration: InputDecoration(
                          labelText: AppTranslations.of('country'),
                          prefixIcon: _selectedCountry == null ? const Icon(Icons.flag) : null,
                          border: const OutlineInputBorder(),
                        ),
                        items: _countries.map((c) {
                          final code = c['code'] as String? ?? '';
                          return DropdownMenuItem(
                            value: c,
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: Image.network(
                                    'https://flagcdn.com/32x24/$code.png',
                                    width: 32,
                                    height: 24,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const SizedBox(width: 32, height: 24),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(c['name'] as String),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCountry = value;
                            _selectedState = null;
                            _states = [];
                            _localities = [];
                            _selectedLocality = null;
                          });
                          if (value != null) {
                            _loadStates(value['id'] as int);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Map<String, dynamic>>(
                        value: _selectedState,
                        decoration: InputDecoration(
                          labelText: AppTranslations.of('state'),
                          prefixIcon: const Icon(Icons.map_outlined),
                          border: const OutlineInputBorder(),
                        ),
                        items: _states.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(s['name'] as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedState = value;
                            _selectedLocality = null;
                            _orgLocalityText = '';
                          });
                          if (value != null) {
                            _loadLocalities(value['id'] as int);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Autocomplete<String>(
                        optionsBuilder: (textEditingValue) {
                          if (textEditingValue.text.isEmpty || _selectedState == null) {
                            return _localities.map((l) => l['name'] as String);
                          }
                          return _localities
                              .map((l) => l['name'] as String)
                              .where((name) => name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (selection) {
                          setState(() {
                            _selectedLocality = selection;
                            _orgLocalityText = selection;
                          });
                        },
                        fieldViewBuilder: (context, textEditingController, focusNode, onSubmitted) {
                          textEditingController.text = _orgLocalityText;
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: AppTranslations.of('locality'),
                              hintText: AppTranslations.of('locality'),
                              prefixIcon: const Icon(Icons.location_city),
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              _orgLocalityText = value;
                              _selectedLocality = null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showDeleteAccountDialog(),
                          icon: const Icon(Icons.delete_forever),
                          label: Text(AppTranslations.of('delete_account')),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? const CircularProgressIndicator()
                              : Text(AppTranslations.of('save')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
