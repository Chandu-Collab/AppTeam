class Post {
  final String postid;
  final String userId;
  final String content;
  final DateTime createdAt;
  final dynamic likes;
  final String location;
  final String username;
  final String userProfileUrl;
  final String? url;

  Post({
    required this.postid,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.likes,
    required this.location,
    required this.username,
    required this.userProfileUrl,
    this.url,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postid: json['postid'],
      userId: json['userId'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      likes: json['likes'],
      location: json['location'],
      username: json['username'],
      userProfileUrl: json['userProfileUrl'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postid': postid,
      'userId': userId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'location': location,
      'username': username,
      'userProfileUrl': userProfileUrl,
      'url': url,
    };
  }
}
