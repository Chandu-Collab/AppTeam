class Follower {
  final String id;
  final String followerId;
  final String followedId;

  Follower({
    required this.id,
    required this.followerId,
    required this.followedId,
  });

  factory Follower.fromJson(Map<String, dynamic> json) {
    return Follower(
      id: json['id'],
      followerId: json['followerId'],
      followedId: json['followedId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'followerId': followerId,
      'followedId': followedId,
    };
  }
}
