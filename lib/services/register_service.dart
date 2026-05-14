import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../dtos/person_request.dart';
import '../dtos/organization_request.dart';

class RegisterService {
  Future<Map<String, dynamic>> registerPerson(RegisterPersonRequest req) async {
    final request = http.MultipartRequest(
      'POST',
      ApiConfig.uri(ApiConfig.registerPerson),
    );

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

    if (streamedResponse.statusCode == 201) {
      return jsonDecode(responseBody);
    }
    throw Exception('Error al registrar: $responseBody');
  }

  Future<Map<String, dynamic>> registerOrganization(
      RegisterOrganizationRequest req) async {
    final request = http.MultipartRequest(
      'POST',
      ApiConfig.uri(ApiConfig.registerOrganization),
    );

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

    if (streamedResponse.statusCode == 201) {
      return jsonDecode(responseBody);
    }
    throw Exception('Error al registrar organización: $responseBody');
  }
}
