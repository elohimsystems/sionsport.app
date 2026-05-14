import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../storage/token_storage.dart';

class EditService {
  static const String baseUrl = 'http://localhost:3000';

  Future<Map<String, dynamic>> getPerson(int id) async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api-sionsport/person/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al cargar persona: ${response.body}');
  }

  Future<Map<String, dynamic>> getOrganization(int id) async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api-sionsport/organization/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al cargar organización: ${response.body}');
  }

  Future<Map<String, dynamic>> editPersonUser({
    required int userId,
    String? email,
    String? language,
    String? timezone,
    String? iddocumento,
    String? first_name,
    String? last_name,
    String? phone_number,
    String? locality,
    String? birthDate,
    int? stateId,
    Uint8List? avatarBytes,
    String? avatarFilename,
    List<int>? profileIds,
    List<int>? disciplineIds,
  }) async {
    final token = await TokenStorage.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api-sionsport/app-auth/edit-user-person'),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (email != null) request.fields['email'] = email;
    if (language != null) request.fields['language'] = language;
    if (timezone != null) request.fields['timezone'] = timezone;
    if (iddocumento != null) request.fields['iddocumento'] = iddocumento;
    if (first_name != null) request.fields['first_name'] = first_name;
    if (last_name != null) request.fields['last_name'] = last_name;
    if (phone_number != null) request.fields['phone_number'] = phone_number;
    if (locality != null) request.fields['locality'] = locality;
    if (birthDate != null) request.fields['birthDate'] = birthDate;
    if (stateId != null) request.fields['stateId'] = stateId.toString();
    if (profileIds != null) request.fields['profileIds'] = profileIds.join(',');
    if (disciplineIds != null) request.fields['disciplineIds'] = disciplineIds.join(',');

    if (avatarBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'avatar',
          avatarBytes,
          filename: avatarFilename ?? 'avatar.jpg',
        ),
      );
    }

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      return jsonDecode(responseBody);
    }
    throw Exception('Error al actualizar persona: $responseBody');
  }

  Future<Map<String, dynamic>> editOrganizationUser({
    required int userId,
    String? email,
    String? language,
    String? timezone,
    String? code,
    String? name,
    String? abbreviated_name,
    String? org_email,
    String? phone,
    String? website,
    String? address,
    String? geolocation,
    String? locality,
    int? stateId,
    Uint8List? logoBytes,
    String? logoFilename,
    List<int>? profileIds,
  }) async {
    final token = await TokenStorage.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api-sionsport/app-auth/edit-user-organization'),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (email != null) request.fields['email'] = email;
    if (language != null) request.fields['language'] = language;
    if (timezone != null) request.fields['timezone'] = timezone;
    if (code != null) request.fields['code'] = code;
    if (name != null) request.fields['name'] = name;
    if (abbreviated_name != null) request.fields['abbreviated_name'] = abbreviated_name;
    if (org_email != null) request.fields['org_email'] = org_email;
    if (phone != null) request.fields['phone'] = phone;
    if (website != null) request.fields['website'] = website;
    if (address != null) request.fields['address'] = address;
    if (geolocation != null) request.fields['geolocation'] = geolocation;
    if (locality != null) request.fields['locality'] = locality;
    if (stateId != null) request.fields['stateId'] = stateId.toString();
    if (profileIds != null) request.fields['profileIds'] = profileIds.join(',');

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

    if (streamedResponse.statusCode == 200) {
      return jsonDecode(responseBody);
    }
    throw Exception('Error al actualizar organización: $responseBody');
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await TokenStorage.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api-sionsport/app-auth/change-password'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al cambiar contraseña: ${response.body}');
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    final token = await TokenStorage.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api-sionsport/app-auth/delete-account'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al eliminar cuenta: ${response.body}');
  }
}