class Chat {
  final String id;
  final List<String> participantIds;
  final List<Message> messages;

  Chat({
    required this.id,
    required this.participantIds,
    required this.messages,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      participantIds: List<String>.from(json['participantIds']),
      messages:
          (json['messages'] as List).map((m) => Message.fromJson(m)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}

class Message {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final String? imageUrl;
  final String? videoUrl;
  final String? attachmentUrl;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.type,
    this.imageUrl,
    this.videoUrl,
    this.attachmentUrl,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.values
          .firstWhere((e) => e.toString() == 'MessageType.${json['type']}'),
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      attachmentUrl: json['attachmentUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'attachmentUrl': attachmentUrl,
    };
  }
}

enum MessageType {
  text,
  image,
  video,
  attachment,
}
