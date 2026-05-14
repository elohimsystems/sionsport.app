import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class RegisterService {
  static const String baseUrl = 'http://localhost:3000';

  Future<Map<String, dynamic>> registerPerson({
    required String username,
    required String password,
    required String email,
    required String iddocumento,
    Uint8List? avatarBytes,
    String? avatarFilename,
    required String first_name,
    required String last_name,
    required String phone_number,
    String? locality,
    String? birthDate,
    int? stateId,
    String? profileIds,
    String? language,
    String? timezone,
    String? disciplineIds,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api-sionsport/app-auth/register-user-person'),
    );

    request.fields['username'] = username;
    request.fields['password'] = password;
    request.fields['email'] = email;
    request.fields['iddocumento'] = iddocumento;
    request.fields['first_name'] = first_name;
    request.fields['last_name'] = last_name;
    request.fields['phone_number'] = phone_number;
    if (locality != null) request.fields['locality'] = locality;
    if (birthDate != null) request.fields['birthDate'] = birthDate;
    if (stateId != null) request.fields['stateId'] = stateId.toString();
    if (profileIds != null) request.fields['profileIds'] = profileIds;
    if (language != null) request.fields['language'] = language;
    if (timezone != null) request.fields['timezone'] = timezone;
    if (disciplineIds != null) request.fields['disciplineIds'] = disciplineIds;

    if (avatarBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'avatar',
          avatarBytes,
          filename: avatarFilename ?? 'avatar.jpg',
        ),
      );
    }
    print('request: $request');

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 201) {
      return jsonDecode(responseBody);
    }
    print('response: $responseBody');
    throw Exception('Error al registrar: $responseBody');
  }

  Future<Map<String, dynamic>> registerOrganization({
    required String username,
    required String password,
    required String email,
    required String code,
    required String name,
    String? abbreviated_name,
    required String org_email,
    String? phone,
    String? website,
    String? address,
    String? geolocation,
    Uint8List? logoBytes,
    String? logoFilename,
    String? locality,
    int? stateId,
    String? profileIds,
    String? language,
    String? timezone,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api-sionsport/app-auth/register-user-organization'),
    );

    request.fields['username'] = username;
    request.fields['password'] = password;
    request.fields['email'] = email;
    request.fields['code'] = code;
    request.fields['name'] = name;
    if (abbreviated_name != null) request.fields['abbreviated_name'] = abbreviated_name;
    request.fields['org_email'] = org_email;
    if (phone != null) request.fields['phone'] = phone;
    if (website != null) request.fields['website'] = website;
    if (address != null) request.fields['address'] = address;
    if (geolocation != null) request.fields['geolocation'] = geolocation;
    if (locality != null) request.fields['locality'] = locality;
    if (stateId != null) request.fields['stateId'] = stateId.toString();
    if (profileIds != null) request.fields['profileIds'] = profileIds;
    if (language != null) request.fields['language'] = language;
    if (timezone != null) request.fields['timezone'] = timezone;

    if (logoBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'logo',
          logoBytes,
          filename: logoFilename ?? 'logo.png',
        ),
      );
    }

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 201) {
      return jsonDecode(responseBody);
    }
    print('Error al registrar organización: $responseBody');
    throw Exception('Error al registrar organización: $responseBody');
  }
}
