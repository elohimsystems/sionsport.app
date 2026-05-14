import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/location.dart';

class LocationService {
  Future<List<Country>> getCountries() async {
    final response = await http.get(
      ApiConfig.uri(ApiConfig.country),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => Country.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al cargar países');
  }

  Future<List<GeoState>> getStatesByCountry(int countryId) async {
    final response = await http.get(
      ApiConfig.uriWithId(ApiConfig.stateByCountry, countryId),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => GeoState.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al cargar estados');
  }

  Future<List<Locality>> getLocalitiesByState(int stateId) async {
    final response = await http.get(
      ApiConfig.uriWithId(ApiConfig.localityByState, stateId),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => Locality.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al cargar localidades');
  }
}
