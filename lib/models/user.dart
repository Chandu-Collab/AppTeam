class User {
  final String id;
  final String userName;
  final String profileName;
  final String email;
  final String mobile;
  final String? url;
  final String? bio;
  final bool? isProfileComplete;
  final bool? hasResume;

  User({
    required this.id,
    required this.userName,
    required this.profileName,
    required this.email,
    required this.mobile,
    this.url,
    this.bio,
    this.isProfileComplete,
    this.hasResume,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      userName: json['userName'] ?? '',
      profileName: json['profileName'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      url: json['url'],
      bio: json['bio'],
      isProfileComplete: json['isProfileComplete'],
      hasResume: json['hasResume'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'profileName': profileName,
      'email': email,
      'mobile': mobile,
      'url': url,
      'bio': bio,
      'isProfileComplete': isProfileComplete,
      'hasResume': hasResume,
    };
  }

  User copyWith({
    String? id,
    String? userName,
    String? profileName,
    String? email,
    String? mobile,
    String? url,
    String? bio,
    bool? isProfileComplete,
    bool? hasResume,
  }) {
    return User(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      profileName: profileName ?? this.profileName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      url: url ?? this.url,
      bio: bio ?? this.bio,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      hasResume: hasResume ?? this.hasResume,
    );
  }
}
