import 'dart:convert';
import 'package:http/http.dart' as http;

class DisciplineService {
  static const String baseUrl = 'http://localhost:3000';

  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api-sionsport/discipline'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Error al obtener disciplinas: ${response.body}');
  }
}
