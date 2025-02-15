class Social {
  final String? youtube;
  final String? twitter;
  final String? facebook;
  final String? linkedin;
  final String? instagram;

  Social({
    this.youtube,
    this.twitter,
    this.facebook,
    this.linkedin,
    this.instagram,
  });

  factory Social.fromJson(Map<String, dynamic> json) {
    return Social(
      youtube: json['youtube'],
      twitter: json['twitter'],
      facebook: json['facebook'],
      linkedin: json['linkedin'],
      instagram: json['instagram'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'youtube': youtube,
      'twitter': twitter,
      'facebook': facebook,
      'linkedin': linkedin,
      'instagram': instagram,
    };
  }
}

