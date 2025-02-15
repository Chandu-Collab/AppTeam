class Education {
  final String school;
  final String degree;
  final String fieldOfStudy;
  final DateTime from;
  final DateTime? to;
  final bool current;
  final String? description;

  Education({
    required this.school,
    required this.degree,
    required this.fieldOfStudy,
    required this.from,
    this.to,
    required this.current,
    this.description,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      school: json['school'],
      degree: json['degree'],
      fieldOfStudy: json['fieldOfStudy'],
      from: DateTime.parse(json['from']),
      to: json['to'] != null ? DateTime.parse(json['to']) : null,
      current: json['current'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'school': school,
      'degree': degree,
      'fieldOfStudy': fieldOfStudy,
      'from': from.toIso8601String(),
      'to': to?.toIso8601String(),
      'current': current,
      'description': description,
    };
  }
}
