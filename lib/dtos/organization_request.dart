import 'dart:typed_data';

class RegisterOrganizationRequest {
  final String username;
  final String password;
  final String email;
  final String code;
  final String name;
  final String? abbreviated_name;
  final String org_email;
  final String? phone;
  final String? website;
  final String? address;
  final String? geolocation;
  final String? locality;
  final int? stateId;
  final String? profileIds;
  final String? language;
  final String? timezone;
  final Uint8List? logoBytes;
  final String? logoFilename;

  RegisterOrganizationRequest({
    required this.username,
    required this.password,
    required this.email,
    required this.code,
    required this.name,
    this.abbreviated_name,
    required this.org_email,
    this.phone,
    this.website,
    this.address,
    this.geolocation,
    this.locality,
    this.stateId,
    this.profileIds,
    this.language,
    this.timezone,
    this.logoBytes,
    this.logoFilename,
  });

  Map<String, String> toFields() {
    final fields = <String, String>{
      'username': username,
      'password': password,
      'email': email,
      'code': code,
      'name': name,
      'org_email': org_email,
    };
    if (abbreviated_name != null) fields['abbreviated_name'] = abbreviated_name!;
    if (phone != null) fields['phone'] = phone!;
    if (website != null) fields['website'] = website!;
    if (address != null) fields['address'] = address!;
    if (geolocation != null) fields['geolocation'] = geolocation!;
    if (locality != null) fields['locality'] = locality!;
    if (stateId != null) fields['stateId'] = stateId.toString();
    if (profileIds != null) fields['profileIds'] = profileIds!;
    if (language != null) fields['language'] = language!;
    if (timezone != null) fields['timezone'] = timezone!;
    return fields;
  }
}

class EditOrganizationRequest {
  final int userId;
  final String? email;
  final String? language;
  final String? timezone;
  final String? code;
  final String? name;
  final String? abbreviated_name;
  final String? org_email;
  final String? phone;
  final String? website;
  final String? address;
  final String? geolocation;
  final String? locality;
  final int? stateId;
  final List<int>? profileIds;
  final Uint8List? logoBytes;
  final String? logoFilename;

  EditOrganizationRequest({
    required this.userId,
    this.email,
    this.language,
    this.timezone,
    this.code,
    this.name,
    this.abbreviated_name,
    this.org_email,
    this.phone,
    this.website,
    this.address,
    this.geolocation,
    this.locality,
    this.stateId,
    this.profileIds,
    this.logoBytes,
    this.logoFilename,
  });

  Map<String, String> toFields() {
    final fields = <String, String>{};
    if (email != null) fields['email'] = email!;
    if (language != null) fields['language'] = language!;
    if (timezone != null) fields['timezone'] = timezone!;
    if (code != null) fields['code'] = code!;
    if (name != null) fields['name'] = name!;
    if (abbreviated_name != null) fields['abbreviated_name'] = abbreviated_name!;
    if (org_email != null) fields['org_email'] = org_email!;
    if (phone != null) fields['phone'] = phone!;
    if (website != null) fields['website'] = website!;
    if (address != null) fields['address'] = address!;
    if (geolocation != null) fields['geolocation'] = geolocation!;
    if (locality != null) fields['locality'] = locality!;
    if (stateId != null) fields['stateId'] = stateId.toString();
    if (profileIds != null) fields['profileIds'] = profileIds!.join(',');
    return fields;
  }
}
