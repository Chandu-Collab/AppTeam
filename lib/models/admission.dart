class Admission {
  final String id;
  final String userId;
  final String admUserurl;
  final String courseId;
  final DateTime admissionDate;
  final String? status;
  final String? courseName;
  final DateTime? startDate;
  final DateTime? endDate;

  Admission({
    required this.id,
    required this.userId,
    required this.admUserurl,
    required this.courseId,
    required this.admissionDate,
    this.status,
    this.courseName,
    this.startDate,
    this.endDate,
  });

  factory Admission.fromJson(Map<String, dynamic> json) {
    return Admission(
      id: json['id'],
      userId: json['userId'],
      admUserurl: json['admUserurl'],
      courseId: json['courseId'],
      admissionDate: DateTime.parse(json['admissionDate']),
      status: json['status'],
      courseName: json['courseName'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'admUserurl': admUserurl,
      'courseId': courseId,
      'admissionDate': admissionDate.toIso8601String(),
      'status': status,
      'courseName': courseName,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }
}
