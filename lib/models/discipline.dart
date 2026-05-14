class Discipline {
  final int id;
  final String name;
  final String? icon;

  Discipline({required this.id, required this.name, this.icon});

  factory Discipline.fromJson(Map<String, dynamic> json) => Discipline(
        id: json['id'] as int,
        name: json['name'] as String,
        icon: json['icon'] as String?,
      );
}
