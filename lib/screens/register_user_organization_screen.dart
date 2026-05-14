import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/register_service.dart';
import '../services/profile_service.dart';
import '../services/location_service.dart';
import '../i18n/app_translations.dart';
import '../i18n/locale_provider.dart';

class RegisterUserOrganizationScreen extends StatefulWidget {
  final String? registerType;
  const RegisterUserOrganizationScreen({super.key, this.registerType});

  @override
  State<RegisterUserOrganizationScreen> createState() =>
      _RegisterUserOrganizationScreenState();
}

class _RegisterUserOrganizationScreenState
    extends State<RegisterUserOrganizationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _registerService = RegisterService();
  final _profileService = ProfileService();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _orgCodeController = TextEditingController();
  final _orgLegalNameController = TextEditingController();
  final _orgAbbreviatedNameController = TextEditingController();
  final _orgEmailController = TextEditingController();
  final _orgPhoneController = TextEditingController();
  final _orgWebsiteController = TextEditingController();
  final _orgAddressController = TextEditingController();
  final _orgGeolocationController = TextEditingController();
  final _picker = ImagePicker();
  Uint8List? _logoBytes;
  String? _logoFilename;

  final Set<int> _selectedProfileIds = <int>{};
  List<Map<String, dynamic>> _profiles = [];
  bool _profilesLoading = true;

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final _locationService = LocationService();
  List<Map<String, dynamic>> _countries = [];
  Map<String, dynamic>? _selectedCountry;
  List<Map<String, dynamic>> _states = [];
  Map<String, dynamic>? _selectedState;
  List<Map<String, dynamic>> _localities = [];
  String? _selectedLocality;
  String _orgLocalityText = '';

  String _selectedLanguage = 'en';
  String _selectedTimezone = 'America/Caracas';

  @override
  void initState() {
    super.initState();
    _selectedLanguage = localeProvider.currentLanguageCode;
    _loadProfiles();
    _loadCountries();
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

  Future<void> _loadCountries() async {
    try {
      final countries = await _locationService.getCountries();
      if (mounted) setState(() => _countries = countries);
    } catch (_) {}
  }

  Future<void> _loadStates(int countryId) async {
    try {
      final states = await _locationService.getStatesByCountry(countryId);
      if (mounted) setState(() {
        _states = states;
        _selectedState = null;
      });
    } catch (_) {
      if (mounted) setState(() {
        _states = [];
        _selectedState = null;
      });
    }
  }

  Future<void> _loadLocalities(int stateId) async {
    try {
      final localities = await _locationService.getLocalitiesByState(stateId);
      if (mounted) setState(() {
        _localities = localities;
        _selectedLocality = null;
      });
    } catch (_) {
      if (mounted) setState(() {
        _localities = [];
        _selectedLocality = null;
      });
    }
  }

  Future<void> _loadProfiles() async {
    try {
      final profiles = await _profileService.getProfilesByTarget('O');
      if (mounted) {
        setState(() {
          _profiles = profiles;
          _profilesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _profilesLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
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

  Future<void> _pickLogo() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();
    setState(() {
      _logoBytes = bytes;
      _logoFilename = xFile.name;
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProfileIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.of('select_profile'))),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _registerService.registerOrganization(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        email: _emailController.text.trim(),
        code: _orgCodeController.text.trim(),
        name: _orgLegalNameController.text.trim(),
        abbreviated_name: _orgAbbreviatedNameController.text.trim().isEmpty
            ? null
            : _orgAbbreviatedNameController.text.trim(),
        org_email: _orgEmailController.text.trim(),
        phone: _orgPhoneController.text.trim().isEmpty
            ? null
            : _orgPhoneController.text.trim(),
        website: _orgWebsiteController.text.trim().isEmpty
            ? null
            : _orgWebsiteController.text.trim(),
        address: _orgAddressController.text.trim().isEmpty
            ? null
            : _orgAddressController.text.trim(),
        geolocation: _orgGeolocationController.text.trim().isEmpty
            ? null
            : _orgGeolocationController.text.trim(),
        logoBytes: _logoBytes,
        logoFilename: _logoFilename,
        locality: (_selectedLocality ?? _orgLocalityText).isEmpty ? null : (_selectedLocality ?? _orgLocalityText),
        stateId: _selectedState?['id'] as int?,
        profileIds: _selectedProfileIds.join(','),
        language: _selectedLanguage,
        timezone: _selectedTimezone,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.of('register_success'))),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppTranslations.of('error')}: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${AppTranslations.of('register')} - ${widget.registerType ?? ""}')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: _logoBytes != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              CircleAvatar(
                                radius: 125,
                                backgroundImage: MemoryImage(_logoBytes!),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                  onPressed: () => setState(() {
                                    _logoBytes = null;
                                    _logoFilename = null;
                                  }),
                                ),
                              ),
                            ],
                          )
                        : InkWell(
                            onTap: _pickLogo,
                            customBorder: const CircleBorder(),
                            child: Container(
                              width: 250,
                              height: 250,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF2A2A2A),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.business, size: 36),
                                    const SizedBox(height: 8),
                                    Text(AppTranslations.of('logo'),
                                        textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                            ),
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
                  decoration: InputDecoration(
                    labelText: AppTranslations.of('username'),
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? AppTranslations.of('enter_username') : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: AppTranslations.of('personal_email'),
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
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: AppTranslations.of('password'),
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return AppTranslations.of('enter_password');
                    if (v.length < 12) return AppTranslations.of('password_min');
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: AppTranslations.of('confirm_password'),
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscureConfirm ? Icons.visibility : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v != _passwordController.text) {
                      return AppTranslations.of('password_mismatch');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedLanguage,
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
                        value: _selectedTimezone,
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
                const SizedBox(height: 16),
                _profilesLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppTranslations.of('profiles'), style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
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
                const SizedBox(height: 16),
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
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? AppTranslations.of('enter_code') : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _orgLegalNameController,
                  decoration: InputDecoration(
                    labelText: AppTranslations.of('legal_name'),
                    prefixIcon: const Icon(Icons.badge),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? AppTranslations.of('enter_legal_name') : null,
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
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return AppTranslations.of('enter_email');
                    if (!v.contains('@')) return AppTranslations.of('invalid_email');
                    return null;
                  },
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
                        .where((name) => name
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (selection) {
                    setState(() {
                      _selectedLocality = selection;
                      _orgLocalityText = selection;
                    });
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode, onSubmitted) {
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
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : Text(AppTranslations.of('register')),
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
