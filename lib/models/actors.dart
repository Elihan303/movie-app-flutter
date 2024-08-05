class Actor {
  final int id;
  final String name;
  final String? profilePath;
  final String character;

  Actor({
    required this.id,
    required this.name,
    required this.profilePath,
    required this.character,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      id: json['id'],
      name: json['name'] ?? '',
      profilePath: json['profile_path'] ?? '',
      character: json['character'] ?? '',
    );
  }
}
