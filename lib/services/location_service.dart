import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static const String baseUrl = 'http://localhost:3000';

  Future<List<Map<String, dynamic>>> getCountries() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api-sionsport/country'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Error al cargar países');
  }

  Future<List<Map<String, dynamic>>> getStatesByCountry(int countryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api-sionsport/state/by-country/$countryId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Error al cargar estados');
  }

  Future<List<Map<String, dynamic>>> getLocalitiesByState(int stateId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api-sionsport/locality/by-state/$stateId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Error al cargar localidades');
  }
}
