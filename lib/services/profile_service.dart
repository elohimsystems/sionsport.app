import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/profile.dart';

class ProfileService {
  Future<List<Profile>> getProfilesByTarget(String target) async {
    final response = await http.get(
      ApiConfig.uriWithId(ApiConfig.profileByTarget, target),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => Profile.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al obtener perfiles: ${response.body}');
  }
}
