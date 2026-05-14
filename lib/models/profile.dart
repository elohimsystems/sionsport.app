class Profile {
  final int id;
  final String name;
  final int? parentId;
  List<Profile>? children;

  Profile({required this.id, required this.name, this.parentId, List<Profile>? children})
      : children = children;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as int,
        name: json['name'] as String,
        parentId: json['parentId'] as int?,
      );

  static List<Profile> buildTree(List<Profile> flat) {
    final byId = {for (final p in flat) p.id: p};
    final roots = <Profile>[];
    for (final p in flat) {
      if (p.parentId != null && byId.containsKey(p.parentId)) {
        final parent = byId[p.parentId]!;
        parent.children ??= [];
        parent.children!.add(p);
      } else {
        roots.add(p);
      }
    }
    return roots;
  }
}
