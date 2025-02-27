class Topic {
  final String id;
  final String courseId;
  final String name;
  final String description;
  final String instructor;
  final String? studyVideoUrl;
  final String? attachment;
  final String title;
  final List<String> question;
  final String userId; // Add userId field

  Topic({
    required this.id,
    required this.courseId,
    required this.name,
    required this.description,
    required this.instructor,
    this.studyVideoUrl,
    this.attachment,
    required this.title,
    required this.question,
    required this.userId, // Add userId to constructor
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      courseId: json['courseId'],
      name: json['name'],
      description: json['description'],
      instructor: json['instructor'],
      studyVideoUrl: json['studyVideoUrl'],
      attachment: json['attachment'],
      title: json['title'],
      question: List<String>.from(json['question']),
      userId: json['userId'], // Add userId to fromJson
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'name': name,
      'description': description,
      'instructor': instructor,
      'studyVideoUrl': studyVideoUrl,
      'attachment': attachment,
      'title': title,
      'question': question,
      'userId': userId, // Add userId to toJson
    };
  }
}
