import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../dtos/person_request.dart';
import '../models/discipline.dart';
import '../models/location.dart';
import '../models/profile.dart';
import '../services/register_service.dart';
import '../services/profile_service.dart';
import '../services/discipline_service.dart';
import '../services/location_service.dart';
import '../i18n/app_translations.dart';
import '../i18n/locale_provider.dart';

class RegisterUserPersonScreen extends StatefulWidget {
  final String? registerType;
  const RegisterUserPersonScreen({super.key, this.registerType});

  @override
  State<RegisterUserPersonScreen> createState() => _RegisterUserPersonScreenState();
}

class _RegisterUserPersonScreenState extends State<RegisterUserPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _registerService = RegisterService();
  final _profileService = ProfileService();
  final _disciplineService = DisciplineService();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _idDocumentoController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _picker = ImagePicker();
  Uint8List? _avatarBytes;
  String? _avatarFilename;

  Set<int> _selectedProfileIds = <int>{};
  List<Profile> _profiles = [];
  bool _profilesLoading = true;

  Set<int> _selectedDisciplineIds = <int>{};
  List<Discipline> _allDisciplines = [];
  bool _disciplinesLoading = true;

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final _locationService = LocationService();
  List<Country> _countries = [];
  Country? _selectedCountry;
  List<GeoState> _states = [];
  GeoState? _selectedState;
  List<Locality> _localities = [];
  String? _selectedLocality;
  String _localityText = '';

  String _selectedLanguage = 'en';
  String _selectedTimezone = 'America/Caracas';

  @override
  void initState() {
    super.initState();
    _selectedLanguage = localeProvider.currentLanguageCode;
    _loadProfiles();
    _loadDisciplines();
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
      final profiles = await _profileService.getProfilesByTarget('P');
      if (mounted) setState(() {
        _profiles = profiles;
        _profilesLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _profilesLoading = false);
    }
  }

  Future<void> _loadDisciplines() async {
    try {
      final disciplines = await _disciplineService.getAll();
      if (mounted) setState(() {
        _allDisciplines = disciplines;
        _disciplinesLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _disciplinesLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _idDocumentoController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      _birthDateController.text =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _pickImage() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();
    setState(() {
      _avatarBytes = bytes;
      _avatarFilename = xFile.name;
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
      await _registerService.registerPerson(RegisterPersonRequest(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        email: _emailController.text.trim(),
        iddocumento: _idDocumentoController.text.trim(),
        avatarBytes: _avatarBytes,
        avatarFilename: _avatarFilename,
        first_name: _firstNameController.text.trim(),
        last_name: _lastNameController.text.trim(),
        phone_number: _phoneNumberController.text.trim(),
        birthDate: _birthDateController.text.trim().isEmpty ? null : _birthDateController.text.trim(),
        locality: (_selectedLocality ?? _localityText).isEmpty ? null : (_selectedLocality ?? _localityText),
        stateId: _selectedState?.id,
        profileIds: _selectedProfileIds.join(','),
        language: _selectedLanguage,
        timezone: _selectedTimezone,
        disciplineIds: _selectedDisciplineIds.join(','),
      ));

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
                    child: _avatarBytes != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              CircleAvatar(
                                radius: 125,
                                backgroundImage: MemoryImage(_avatarBytes!),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: IconButton(
                                  icon: const Icon(Icons.close_rounded, color: Colors.red, size: 28),
                                  onPressed: () => setState(() {
                                    _avatarBytes = null;
                                    _avatarFilename = null;
                                  }),
                                ),
                              ),
                            ],
                          )
                        : InkWell(
                            onTap: _pickImage,
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
                                    const Icon(Icons.camera_alt, size: 36),
                                    const SizedBox(height: 8),
                                    Text(AppTranslations.of('select_photo'), textAlign: TextAlign.center),
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
                  validator: (v) => v == null || v.trim().isEmpty ? AppTranslations.of('enter_username') : null,
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
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: AppTranslations.of('password'),
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
                      icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v != _passwordController.text) return AppTranslations.of('password_mismatch');
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
                        .where((name) => name
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (selection) {
                    setState(() {
                      _selectedLocality = selection;
                      _localityText = selection;
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
