class Country {
  final int id;
  final String code;
  final String name;

  Country({required this.id, required this.code, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json['id'] as int,
        code: json['code'] as String,
        name: json['name'] as String,
      );
}

class GeoState {
  final int id;
  final String name;

  GeoState({required this.id, required this.name});

  factory GeoState.fromJson(Map<String, dynamic> json) => GeoState(
        id: json['id'] as int,
        name: json['name'] as String,
      );
}

class Locality {
  final String name;

  Locality({required this.name});

  factory Locality.fromJson(Map<String, dynamic> json) =>
      Locality(name: json['name'] as String);
}
