class StateData {
  final int id;
  final CountryRef? country;
  final int? countryId;

  StateData({required this.id, this.country, this.countryId});

  factory StateData.fromJson(Map<String, dynamic> json) => StateData(
        id: json['id'] as int,
        country: json['country'] != null
            ? CountryRef.fromJson(json['country'] as Map<String, dynamic>)
            : null,
        countryId: json['countryId'] as int?,
      );
}

class CountryRef {
  final int id;

  CountryRef({required this.id});

  factory CountryRef.fromJson(Map<String, dynamic> json) =>
      CountryRef(id: json['id'] as int);
}

class IdItem {
  final int id;

  IdItem({required this.id});

  factory IdItem.fromJson(Map<String, dynamic> json) =>
      IdItem(id: json['id'] as int);
}
