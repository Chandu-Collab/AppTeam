class Project {
  final String name;
  final String companyName;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> skills;
  final String role;
  final String? projectDesc;
  final String projectName;
  final String clientName;
  final String userId; // Add userId field

  Project({
    required this.name,
    required this.companyName,
    required this.startDate,
    this.endDate,
    required this.skills,
    required this.role,
    this.projectDesc,
    required this.projectName,
    required this.clientName,
    required this.userId, // Add userId to constructor
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      name: json['name'],
      companyName: json['companyName'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      skills: List<String>.from(json['skills']),
      role: json['role'],
      projectDesc: json['projectDesc'],
      projectName: json['projectName'],
      clientName: json['clientName'],
      userId: json['userId'], // Add userId to fromJson
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'companyName': companyName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'skills': skills,
      'role': role,
      'projectDesc': projectDesc,
      'projectName': projectName,
      'clientName': clientName,
      'userId': userId, // Add userId to toJson
    };
  }
}