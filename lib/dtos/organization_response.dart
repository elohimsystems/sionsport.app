import 'location_response.dart';

class OrganizationResponse {
  final String? logo;
  final OrgUserData? user;
  final String? code;
  final String? name;
  final String? abbreviated_name;
  final String? phone;
  final String? website;
  final String? address;
  final String? geolocation;
  final String? locality;
  final StateData? state;

  OrganizationResponse({
    this.logo,
    this.user,
    this.code,
    this.name,
    this.abbreviated_name,
    this.phone,
    this.website,
    this.address,
    this.geolocation,
    this.locality,
    this.state,
  });

  factory OrganizationResponse.fromJson(Map<String, dynamic> json) =>
      OrganizationResponse(
        logo: json['logo'] as String?,
        user: json['user'] != null
            ? OrgUserData.fromJson(json['user'] as Map<String, dynamic>)
            : null,
        code: json['code'] as String?,
        name: json['name'] as String?,
        abbreviated_name: json['abbreviated_name'] as String?,
        phone: json['phone'] as String?,
        website: json['website'] as String?,
        address: json['address'] as String?,
        geolocation: json['geolocation'] as String?,
        locality: json['locality'] as String?,
        state: json['state'] != null
            ? StateData.fromJson(json['state'] as Map<String, dynamic>)
            : null,
      );
}

class OrgUserData {
  final String? email;
  final String? username;
  final String? language;
  final String? timezone;
  final List<IdItem>? profiles;

  OrgUserData({
    this.email,
    this.username,
    this.language,
    this.timezone,
    this.profiles,
  });

  factory OrgUserData.fromJson(Map<String, dynamic> json) => OrgUserData(
        email: json['email'] as String?,
        username: json['username'] as String?,
        language: json['language'] as String?,
        timezone: json['timezone'] as String?,
        profiles: json['profiles'] != null
            ? (json['profiles'] as List<dynamic>)
                .map((e) => IdItem.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
      );
}
