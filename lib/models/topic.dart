class Topic {
  final String id;
  final String name;
  final String description;
  final String instructor;
  final String? studyVideoUrl;
  final String? attachment;
  final String title;
  final List<String> question;

  Topic({
    required this.id,
    required this.name,
    required this.description,
    required this.instructor,
    this.studyVideoUrl,
    this.attachment,
    required this.title,
    required this.question,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      instructor: json['instructor'],
      studyVideoUrl: json['studyVideoUrl'],
      attachment: json['attachment'],
      title: json['title'],
      question: List<String>.from(json['question']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'instructor': instructor,
      'studyVideoUrl': studyVideoUrl,
      'attachment': attachment,
      'title': title,
      'question': question,
    };
  }
}
