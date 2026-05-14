import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/token_storage.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000';
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api-sionsport/app-auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await TokenStorage.saveToken(data['access_token']);
      await TokenStorage.saveFullName(data['user']['nameToShow']);
      await TokenStorage.saveTarget(data['user']['target']);
      await TokenStorage.saveImage(data['user']['imagetoShow']);
      await TokenStorage.saveEntityId(data['user']['entityId']);
      return data;
    }
    throw Exception('Login failed: ${response.body}');
  }
}