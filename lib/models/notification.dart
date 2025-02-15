import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  final String id;
  final String type;
  final String content;
  final String senderId;
  final String recipientId;
  final DateTime timestamp;
  final bool isRead;

  Notification({
    required this.id,
    required this.type,
    required this.content,
    required this.senderId,
    required this.recipientId,
    required this.timestamp,
    this.isRead = false,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      type: json['type'],
      content: json['content'],
      senderId: json['senderId'],
      recipientId: json['recipientId'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'senderId': senderId,
      'recipientId': recipientId,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}

