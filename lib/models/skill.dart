class Skill {
  String? id;
  String name;
  String proficiency;
  String? description;

  Skill({
    this.id,
    required this.name,
    required this.proficiency,
    this.description,
  });

  /// Convert a Skill object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'proficiency': proficiency,
      'description': description,
    };
  }

  /// Create a Skill object from a JSON map
  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'],
      name: json['name'],
      proficiency: json['proficiency'],
      description: json['description'],
    );
  }
}
