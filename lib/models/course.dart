import 'package:taurusai/models/topic.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final List<String> category;
  final List<String> skill;
  final String instructorUrl;
  final List<Topic> topics;
  final String duration;
  final String level;
  final double price;
  final String url;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final String? createrId;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.skill,
    required this.instructorUrl,
    required this.topics,
    required this.duration,
    required this.level,
    required this.price,
    required this.url,
    this.startDate,
    this.endDate,
    required this.status,
    required this.createrId,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: List<String>.from(json['category']),
      skill: List<String>.from(json['skill']),
      instructorUrl: json['instructorUrl'],
      topics: (json['topics'] as List).map((t) => Topic.fromJson(t)).toList(),
      duration: json['duration'],
      level: json['level'],
      price: json['price'],
      url: json['url'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      status: json['status'],
      createrId: json['createrId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'skill': skill,
      'instructorUrl': instructorUrl,
      'topics': topics.map((t) => t.toJson()).toList(),
      'duration': duration,
      'level': level,
      'price': price,
      'url': url,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status,
      'createrId': createrId,
    };
  }
}
