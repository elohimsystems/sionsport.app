import 'dart:typed_data';

class RegisterPersonRequest {
  final String username;
  final String password;
  final String email;
  final String iddocumento;
  final String first_name;
  final String last_name;
  final String phone_number;
  final String? locality;
  final String? birthDate;
  final int? stateId;
  final String? profileIds;
  final String? language;
  final String? timezone;
  final String? disciplineIds;
  final Uint8List? avatarBytes;
  final String? avatarFilename;

  RegisterPersonRequest({
    required this.username,
    required this.password,
    required this.email,
    required this.iddocumento,
    required this.first_name,
    required this.last_name,
    required this.phone_number,
    this.locality,
    this.birthDate,
    this.stateId,
    this.profileIds,
    this.language,
    this.timezone,
    this.disciplineIds,
    this.avatarBytes,
    this.avatarFilename,
  });

  Map<String, String> toFields() {
    final fields = <String, String>{
      'username': username,
      'password': password,
      'email': email,
      'iddocumento': iddocumento,
      'first_name': first_name,
      'last_name': last_name,
      'phone_number': phone_number,
    };
    if (locality != null) fields['locality'] = locality!;
    if (birthDate != null) fields['birthDate'] = birthDate!;
    if (stateId != null) fields['stateId'] = stateId.toString();
    if (profileIds != null) fields['profileIds'] = profileIds!;
    if (language != null) fields['language'] = language!;
    if (timezone != null) fields['timezone'] = timezone!;
    if (disciplineIds != null) fields['disciplineIds'] = disciplineIds!;
    return fields;
  }
}

class EditPersonRequest {
  final int userId;
  final String? email;
  final String? language;
  final String? timezone;
  final String? iddocumento;
  final String? first_name;
  final String? last_name;
  final String? phone_number;
  final String? locality;
  final String? birthDate;
  final int? stateId;
  final List<int>? profileIds;
  final List<int>? disciplineIds;
  final Uint8List? avatarBytes;
  final String? avatarFilename;

  EditPersonRequest({
    required this.userId,
    this.email,
    this.language,
    this.timezone,
    this.iddocumento,
    this.first_name,
    this.last_name,
    this.phone_number,
    this.locality,
    this.birthDate,
    this.stateId,
    this.profileIds,
    this.disciplineIds,
    this.avatarBytes,
    this.avatarFilename,
  });

  Map<String, String> toFields() {
    final fields = <String, String>{};
    if (email != null) fields['email'] = email!;
    if (language != null) fields['language'] = language!;
    if (timezone != null) fields['timezone'] = timezone!;
    if (iddocumento != null) fields['iddocumento'] = iddocumento!;
    if (first_name != null) fields['first_name'] = first_name!;
    if (last_name != null) fields['last_name'] = last_name!;
    if (phone_number != null) fields['phone_number'] = phone_number!;
    if (locality != null) fields['locality'] = locality!;
    if (birthDate != null) fields['birthDate'] = birthDate!;
    if (stateId != null) fields['stateId'] = stateId.toString();
    if (profileIds != null) fields['profileIds'] = profileIds!.join(',');
    if (disciplineIds != null) fields['disciplineIds'] = disciplineIds!.join(',');
    return fields;
  }
}
