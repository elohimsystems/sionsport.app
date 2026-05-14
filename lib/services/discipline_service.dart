import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/discipline.dart';

class DisciplineService {
  Future<List<Discipline>> getAll() async {
    final response = await http.get(
      ApiConfig.uri(ApiConfig.discipline),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => Discipline.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al obtener disciplinas: ${response.body}');
  }
}
