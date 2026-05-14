import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../dtos/auth_request.dart';
import '../dtos/person_request.dart';
import '../dtos/organization_request.dart';
import '../dtos/person_response.dart';
import '../dtos/organization_response.dart';
import '../storage/token_storage.dart';

class EditService {
  Future<PersonResponse> getPerson(int id) async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      ApiConfig.uriWithId(ApiConfig.person, id),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return PersonResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Error al cargar persona: ${response.body}');
  }

  Future<OrganizationResponse> getOrganization(int id) async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      ApiConfig.uriWithId(ApiConfig.organization, id),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return OrganizationResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Error al cargar organización: ${response.body}');
  }

  Future<Map<String, dynamic>> editPersonUser(EditPersonRequest req) async {
    final token = await TokenStorage.getToken();
    final request = http.MultipartRequest(
      'POST',
      ApiConfig.uri(ApiConfig.editPerson),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields.addAll(req.toFields());

    if (req.avatarBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'avatar',
          req.avatarBytes!,
          filename: req.avatarFilename ?? 'avatar.jpg',
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

  Future<Map<String, dynamic>> editOrganizationUser(
      EditOrganizationRequest req) async {
    final token = await TokenStorage.getToken();
    final request = http.MultipartRequest(
      'POST',
      ApiConfig.uri(ApiConfig.editOrganization),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields.addAll(req.toFields());

    if (req.logoBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'logo',
          req.logoBytes!,
          filename: req.logoFilename ?? 'logo.png',
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

  Future<Map<String, dynamic>> changePassword(
      ChangePasswordRequest req) async {
    final token = await TokenStorage.getToken();
    final response = await http.post(
      ApiConfig.uri(ApiConfig.changePassword),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(req.toJson()),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al cambiar contraseña: ${response.body}');
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    final token = await TokenStorage.getToken();
    final response = await http.post(
      ApiConfig.uri(ApiConfig.deleteAccount),
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
