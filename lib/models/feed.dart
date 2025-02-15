class Feed {
  final String id;
  final String userId;
  final String postId;
  final String type;
  final String url;
  final String userProfileImg;
  final String username;
  final DateTime? commentDate;
  final DateTime? timestamp;

  Feed({
    required this.id,
    required this.userId,
    required this.postId,
    required this.type,
    required this.url,
    required this.userProfileImg,
    required this.username,
    this.commentDate,
    this.timestamp,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      id: json['id'],
      userId: json['userId'],
      postId: json['postId'],
      type: json['type'],
      url: json['url'],
      userProfileImg: json['userProfileImg'],
      username: json['username'],
      commentDate: json['commentDate'] != null
          ? DateTime.parse(json['commentDate'])
          : null,
      timestamp:
          json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'postId': postId,
      'type': type,
      'url': url,
      'userProfileImg': userProfileImg,
      'username': username,
      'commentDate': commentDate?.toIso8601String(),
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}
