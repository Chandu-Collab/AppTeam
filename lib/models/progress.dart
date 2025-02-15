class Progress {
  final String id;
  final String userId;
  final String courseId;
  final double percentageCompleted;
  final DateTime lastAccessDate;

  Progress({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.percentageCompleted,
    required this.lastAccessDate,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['id'],
      userId: json['userId'],
      courseId: json['courseId'],
      percentageCompleted: json['percentageCompleted'],
      lastAccessDate: DateTime.parse(json['lastAccessDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'courseId': courseId,
      'percentageCompleted': percentageCompleted,
      'lastAccessDate': lastAccessDate.toIso8601String(),
    };
  }
}
