import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../dtos/auth_request.dart';
import '../dtos/auth_response.dart';
import '../storage/token_storage.dart';

class AuthService {
  Future<LoginResponse> login(LoginRequest req) async {
    final response = await http.post(
      ApiConfig.uri(ApiConfig.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(req.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final result = LoginResponse.fromJson(data);
      await TokenStorage.saveToken(result.accessToken);
      await TokenStorage.saveFullName(result.user.nameToShow);
      await TokenStorage.saveTarget(result.user.target);
      await TokenStorage.saveImage(result.user.imagetoShow);
      await TokenStorage.saveEntityId(result.user.entityId);
      return result;
    }
    throw Exception('Login failed: ${response.body}');
  }
}
