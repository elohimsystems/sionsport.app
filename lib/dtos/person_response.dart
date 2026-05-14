import 'location_response.dart';

class PersonResponse {
  final String? avatar;
  final PersonUserData? user;
  final String? iddocumento;
  final String? first_name;
  final String? last_name;
  final String? phone_number;
  final String? birth_date;
  final String? locality;
  final List<IdItem>? disciplines;
  final StateData? state;

  PersonResponse({
    this.avatar,
    this.user,
    this.iddocumento,
    this.first_name,
    this.last_name,
    this.phone_number,
    this.birth_date,
    this.locality,
    this.disciplines,
    this.state,
  });

  factory PersonResponse.fromJson(Map<String, dynamic> json) => PersonResponse(
        avatar: json['avatar'] as String?,
        user: json['user'] != null
            ? PersonUserData.fromJson(json['user'] as Map<String, dynamic>)
            : null,
        iddocumento: json['iddocumento'] as String?,
        first_name: json['first_name'] as String?,
        last_name: json['last_name'] as String?,
        phone_number: json['phone_number'] as String?,
        birth_date: json['birth_date'] as String?,
        locality: json['locality'] as String?,
        disciplines: json['disciplines'] != null
            ? (json['disciplines'] as List<dynamic>)
                .map((e) => IdItem.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
        state: json['state'] != null
            ? StateData.fromJson(json['state'] as Map<String, dynamic>)
            : null,
      );
}

class PersonUserData {
  final String? email;
  final String? username;
  final String? language;
  final String? timezone;
  final List<IdItem>? profiles;

  PersonUserData({
    this.email,
    this.username,
    this.language,
    this.timezone,
    this.profiles,
  });

  factory PersonUserData.fromJson(Map<String, dynamic> json) => PersonUserData(
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
