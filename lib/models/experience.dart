class Experience {
  final String title;
  final String company;
  final String? location;
  final DateTime from;
  final DateTime? to;
  final bool current;
  final String? description;
  final String jobTitle;
  final List<String> skill;

  Experience({
    required this.title,
    required this.company,
    this.location,
    required this.from,
    this.to,
    required this.current,
    this.description,
    required this.jobTitle,
    required this.skill,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      title: json['title'],
      company: json['company'],
      location: json['location'],
      from: DateTime.parse(json['from']),
      to: json['to'] != null ? DateTime.parse(json['to']) : null,
      current: json['current'],
      description: json['description'],
      jobTitle: json['jobTitle'],
      skill: List<String>.from(json['skill']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'company': company,
      'location': location,
      'from': from.toIso8601String(),
      'to': to?.toIso8601String(),
      'current': current,
      'description': description,
      'jobTitle': jobTitle,
      'skill': skill,
    };
  }
}
