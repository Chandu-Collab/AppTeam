class Dependent {
  final String name;
  final String relation;
  final List<String> phone;
  final String location;
  final String? description;

  Dependent({
    required this.name,
    required this.relation,
    required this.phone,
    required this.location,
    this.description,
  });

  factory Dependent.fromJson(Map<String, dynamic> json) {
    return Dependent(
      name: json['name'],
      relation: json['relation'],
      phone: List<String>.from(json['phone']),
      location: json['location'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relation': relation,
      'phone': phone,
      'location': location,
      'description': description,
    };
  }
}
