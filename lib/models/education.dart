class Education {
  final String id;
  final String school;
  final String degree;
  final String fieldOfStudy;
  final DateTime from;
  final DateTime? to;
  final bool current;
  final String? description;
  final String userId; // Add userId field

  Education({
    required this.id,
    required this.school,
    required this.degree,
    required this.fieldOfStudy,
    required this.from,
    this.to,
    required this.current,
    this.description,
    required this.userId, // Add userId to constructor
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'],
      school: json['school'],
      degree: json['degree'],
      fieldOfStudy: json['fieldOfStudy'],
      from: DateTime.parse(json['from']),
      to: json['to'] != null ? DateTime.parse(json['to']) : null,
      current: json['current'],
      description: json['description'],
      userId: json['userId'], // Add userId to fromJson
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school': school,
      'degree': degree,
      'fieldOfStudy': fieldOfStudy,
      'from': from.toIso8601String(),
      'to': to?.toIso8601String(),
      'current': current,
      'description': description,
      'userId': userId, // Add userId to toJson
    };
  }
}
