class Comment {
  final String id;
  final String userId;
  final String postId;
  final String content;
  final DateTime createdAt;
  final String? userUrl;
  final dynamic likes;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.content,
    required this.createdAt,
    this.userUrl,
    this.likes,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['userId'],
      postId: json['postId'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      userUrl: json['userUrl'],
      likes: json['likes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'postId': postId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'userUrl': userUrl,
      'likes': likes,
    };
  }
}
