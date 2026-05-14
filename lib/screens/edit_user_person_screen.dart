import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../config/app_routes.dart';
import '../models/discipline.dart';
import '../models/location.dart';
import '../models/profile.dart';
import '../dtos/auth_request.dart';
import '../dtos/person_request.dart';
import '../services/edit_service.dart';
import '../services/location_service.dart';
import '../services/profile_service.dart';
import '../services/discipline_service.dart';
import '../i18n/app_translations.dart';
import '../i18n/locale_provider.dart';
import '../storage/token_storage.dart';

class EditUserPersonScreen extends StatefulWidget {
  const EditUserPersonScreen({super.key});

  @override
  State<EditUserPersonScreen> createState() => _EditUserPersonScreenState();
}

class _EditUserPersonScreenState extends State<EditUserPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _editService = EditService();
  final _locationService = LocationService();
  final _profileService = ProfileService();
  final _disciplineService = DisciplineService();
  final _picker = ImagePicker();

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _idDocumentoController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _birthDateController = TextEditingController();

  Uint8List? _avatarBytes;
  String? _existingAvatar;
  bool _avatarChanged = false;

  String _selectedLanguage = 'en';
  String _selectedTimezone = 'America/Caracas';

  bool _loading = true;
  bool _saving = false;
  int? _entityId;

  List<Country> _countries = [];
  Country? _selectedCountry;
  List<GeoState> _states = [];
  GeoState? _selectedState;
  List<Locality> _localities = [];
  String? _selectedLocality;
  String _localityText = '';

  List<Profile> _profiles = [];
  bool _profilesLoading = true;
  Set<int> _selectedProfileIds = <int>{};

  List<Discipline> _allDisciplines = [];
  bool _disciplinesLoading = true;
  Set<int> _selectedDisciplineIds = <int>{};

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
          SnackBar(content: Text('${AppTranslations.of('error')}: No se encontró ID de persona')),
        );
        Navigator.pop(context);
      }
      return;
    }
    _entityId = entityId;

    try {
      final person = await _editService.getPerson(entityId);
      final countries = await _locationService.getCountries();
      final allProfiles = await _profileService.getProfilesByTarget('P');
      final allDisciplines = await _disciplineService.getAll();

      if (mounted) {
        setState(() {
          _existingAvatar = person.avatar;

          _emailController.text = person.user?.email ?? '';
          _usernameController.text = person.user?.username ?? '';
          _selectedLanguage = person.user?.language ?? 'en';
          _selectedTimezone = person.user?.timezone ?? 'America/Caracas';

          _idDocumentoController.text = person.iddocumento ?? '';
          _firstNameController.text = person.first_name ?? '';
          _lastNameController.text = person.last_name ?? '';
          _phoneNumberController.text = person.phone_number ?? '';
          _birthDateController.text = person.birth_date ?? '';
          _localityText = person.locality ?? '';

          _profiles = allProfiles;
          _selectedProfileIds = person.user?.profiles?.map((p) => p.id).toSet() ?? {};
          _profilesLoading = false;

          _allDisciplines = allDisciplines;
          _selectedDisciplineIds = person.disciplines?.map((d) => d.id).toSet() ?? {};
          _disciplinesLoading = false;

          _countries = countries;

          final stateData = person.state;
          if (stateData != null) {
            final countryId = stateData.country?.id ?? stateData.countryId;
            final matchedCountry = countryId != null
                ? _countries.where((c) => c.id == countryId).firstOrNull
                : null;
            if (matchedCountry != null) {
              _selectedCountry = matchedCountry;
              _loadStates(matchedCountry.id).then((_) {
                final state = _states.where((s) => s.id == stateData.id).firstOrNull;
                if (state != null) {
                  _selectedState = state;
                  _loadLocalities(state.id);
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

  Future<void> _pickImage() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();
    setState(() {
      _avatarBytes = bytes;
      _avatarChanged = true;
    });
  }

  Future<void> _pickDate() async {
    final initial = _birthDateController.text.isNotEmpty
        ? DateTime.tryParse(_birthDateController.text) ?? DateTime.now().subtract(const Duration(days: 365 * 18))
        : DateTime.now().subtract(const Duration(days: 365 * 18));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      _birthDateController.text =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_entityId == null) return;

    setState(() => _saving = true);

    try {
      await _editService.editPersonUser(EditPersonRequest(
        userId: _entityId!,
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        language: _selectedLanguage,
        timezone: _selectedTimezone,
        first_name: _firstNameController.text.trim(),
        last_name: _lastNameController.text.trim(),
        iddocumento: _idDocumentoController.text.trim(),
        phone_number: _phoneNumberController.text.trim(),
        locality: (_selectedLocality ?? _localityText).isEmpty ? null : (_selectedLocality ?? _localityText),
        birthDate: _birthDateController.text.trim().isEmpty ? null : _birthDateController.text.trim(),
        stateId: _selectedState?.id,
        avatarBytes: _avatarChanged ? _avatarBytes : null,
        avatarFilename: null,
        profileIds: _selectedProfileIds.toList(),
        disciplineIds: _selectedDisciplineIds.toList(),
      ));

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
        await _editService.changePassword(ChangePasswordRequest(
          currentPassword: currentController.text,
          newPassword: newController.text,
        ));
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
        Navigator.pushReplacementNamed(context, AppRoutes.home);
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
    _idDocumentoController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _showDisciplinePicker() async {
    final result = await showDialog<Set<int>>(
      context: context,
      builder: (ctx) {
        var tempSelected = Set<int>.from(_selectedDisciplineIds);
        final searchController = TextEditingController();
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final searchQuery = searchController.text.toLowerCase();
            return AlertDialog(
              title: const Text('Seleccionar Disciplinas'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: searchController,
                        onChanged: (_) => setDialogState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Buscar disciplina...',
                          prefixIcon: const Icon(Icons.search, color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        childAspectRatio: 2,
                        children: _allDisciplines
                            .where((d) => searchQuery.isEmpty || d.name.toLowerCase().contains(searchQuery))
                            .map((d) {
                          final id = d.id;
                          final checked = tempSelected.contains(id);
                          return InkWell(
                            onTap: () => setDialogState(() {
                              if (checked) {
                                tempSelected.remove(id);
                              } else {
                                tempSelected.add(id);
                              }
                            }),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: checked ? Colors.blue : Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: checked ? Colors.blue.withOpacity(0.25) : Colors.white24,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(_disciplineIcon(d.icon), size: 28, color: Colors.white),
                                  const SizedBox(height: 4),
                                  Text(
                                    d.name,
                                    style: TextStyle(fontSize: 12, color: Colors.white),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, tempSelected),
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      },
    );
    if (result != null) {
      setState(() => _selectedDisciplineIds = result);
    }
  }

  IconData _disciplineIcon(String? icon) {
    switch (icon) {
      case 'sports_soccer': return Icons.sports_soccer;
      case 'sports_basketball': return Icons.sports_basketball;
      case 'sports_baseball': return Icons.sports_baseball;
      case 'sports_tennis': return Icons.sports_tennis;
      case 'sports_volleyball': return Icons.sports_volleyball;
      case 'pool': return Icons.pool;
      case 'directions_run': return Icons.directions_run;
      case 'directions_bike': return Icons.directions_bike;
      case 'sports_mma': return Icons.sports_mma;
      case 'sports_martial_arts': return Icons.sports_martial_arts;
      case 'fitness_center': return Icons.fitness_center;
      case 'golf_course': return Icons.golf_course;
      case 'sports_hockey': return Icons.sports_hockey;
      case 'sports_rugby': return Icons.sports_rugby;
      case 'sports_football': return Icons.sports_football;
      case 'sports_handball': return Icons.sports_handball;
      case 'surfing': return Icons.surfing;
      case 'skateboarding': return Icons.skateboarding;
      case 'snowboarding': return Icons.snowboarding;
      case 'downhill_skiing': return Icons.downhill_skiing;
      case 'sailing': return Icons.sailing;
      case 'rowing': return Icons.rowing;
      case 'kayaking': return Icons.kayaking;
      case 'scuba_diving': return Icons.scuba_diving;
      case 'roller_skating': return Icons.roller_skating;
      case 'sports_kabaddi': return Icons.sports_kabaddi;
      case 'psychology': return Icons.psychology;
      case 'sports_esports': return Icons.sports_esports;
      case 'hiking': return Icons.hiking;
      case 'self_improvement': return Icons.self_improvement;
      case 'music_note': return Icons.music_note;
      case 'directions_walk': return Icons.directions_walk;
      default: return Icons.sports_kabaddi;
    }
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
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 100,
                                backgroundColor: const Color(0xFF2A2A2A),
                                backgroundImage: _avatarBytes != null
                                    ? MemoryImage(_avatarBytes!)
                                    : (_existingAvatar != null
                                        ? NetworkImage(ApiConfig.imageUrl(_existingAvatar!))
                                        : null),
                                child: _avatarBytes == null && _existingAvatar == null
                                    ? const Icon(Icons.camera_alt, size: 40)
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
                              if (_avatarBytes != null)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      _avatarBytes = null;
                                      _avatarChanged = true;
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
                                  final id = p.id;
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
                                    title: Text(p.name),
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
                        AppTranslations.of('personal_data'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _idDocumentoController,
                        decoration: InputDecoration(
                          labelText: AppTranslations.of('id_document'),
                          prefixIcon: const Icon(Icons.badge),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? AppTranslations.of('enter_id_document') : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: AppTranslations.of('first_name'),
                          prefixIcon: const Icon(Icons.person),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? AppTranslations.of('enter_first_name') : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: AppTranslations.of('last_name'),
                          prefixIcon: const Icon(Icons.person),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? AppTranslations.of('enter_last_name') : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: AppTranslations.of('phone'),
                          prefixIcon: const Icon(Icons.phone),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? AppTranslations.of('enter_phone') : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _birthDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: AppTranslations.of('birth_date'),
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: const OutlineInputBorder(),
                        ),
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppTranslations.of('location'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Country>(
                        value: _selectedCountry,
                        decoration: InputDecoration(
                          labelText: AppTranslations.of('country'),
                          prefixIcon: _selectedCountry == null ? const Icon(Icons.flag) : null,
                          border: const OutlineInputBorder(),
                        ),
                        items: _countries.map((c) {
                          final code = c.code;
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
                                Text(c.name),
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
                            _loadStates(value.id);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<GeoState>(
                        value: _selectedState,
                        decoration: InputDecoration(
                          labelText: AppTranslations.of('state'),
                          prefixIcon: const Icon(Icons.map_outlined),
                          border: const OutlineInputBorder(),
                        ),
                        items: _states.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(s.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedState = value;
                            _selectedLocality = null;
                            _localityText = '';
                          });
                          if (value != null) {
                            _loadLocalities(value.id);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Autocomplete<String>(
                        optionsBuilder: (textEditingValue) {
                          if (textEditingValue.text.isEmpty || _selectedState == null) {
                            return _localities.map((l) => l.name);
                          }
                          return _localities
                              .map((l) => l.name)
                              .where((name) => name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (selection) {
                          setState(() {
                            _selectedLocality = selection;
                            _localityText = selection;
                          });
                        },
                        fieldViewBuilder: (context, textEditingController, focusNode, onSubmitted) {
                          textEditingController.text = _localityText;
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
                              _localityText = value;
                              _selectedLocality = null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _disciplinesLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(AppTranslations.of('disciplines'), style: const TextStyle(fontSize: 16)),
                                    const Spacer(),
                                    TextButton.icon(
                                      onPressed: () => _showDisciplinePicker(),
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text('Seleccionar'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (_allDisciplines.isNotEmpty && _selectedDisciplineIds.isEmpty)
                                  Text('Ninguna disciplina seleccionada',
                                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                                if (_selectedDisciplineIds.isNotEmpty)
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: _selectedDisciplineIds.map((id) {
                                      final d = _allDisciplines.firstWhere(
                                        (d) => d.id == id,
                                      );
                                      return Chip(
                                        avatar: Icon(_disciplineIcon(d.icon), size: 18, color: Colors.white),
                                        label: Text(d.name, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                        deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white70),
                                        onDeleted: () => setState(() => _selectedDisciplineIds.remove(id)),
                                        backgroundColor: Colors.white24,
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                      const SizedBox(height: 24),
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
