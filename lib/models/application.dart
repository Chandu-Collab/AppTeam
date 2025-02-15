class Application {
  final String id;
  final String userId;
  final String jobId;
  final String status;
  final String? jobTitle;
  final String? jobswipeStatus;
  final String? portfolioUrl;
  final String? portfolio;
  final DateTime? applicationDate;
  final DateTime? chnageDate;

  Application({
    required this.id,
    required this.userId,
    required this.jobId,
    required this.status,
    this.jobTitle,
    this.jobswipeStatus,
    this.portfolioUrl,
    this.portfolio,
    this.applicationDate,
    this.chnageDate,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      userId: json['userId'],
      jobId: json['jobId'],
      status: json['status'],
      jobTitle: json['jobTitle'],
      jobswipeStatus: json['jobswipeStatus'],
      portfolioUrl: json['portfolioUrl'],
      portfolio: json['portfolio'],
      applicationDate: json['applicationDate'] != null
          ? DateTime.parse(json['applicationDate'])
          : null,
      chnageDate: json['chnageDate'] != null
          ? DateTime.parse(json['chnageDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'jobId': jobId,
      'status': status,
      'jobTitle': jobTitle,
      'jobswipeStatus': jobswipeStatus,
      'portfolioUrl': portfolioUrl,
      'portfolio': portfolio,
      'applicationDate': applicationDate?.toIso8601String(),
      'chnageDate': chnageDate?.toIso8601String(),
    };
  }
}
