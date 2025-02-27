class Certificate {
  final String id;
  final String name;
  final String issuingOrganization;
  final DateTime issueDate;
  final DateTime? expirationDate;
  final String? credentialId;
  final String? credentialUrl;
  final String userId; // Add userId field

  Certificate({
    required this.id,
    required this.name,
    required this.issuingOrganization,
    required this.issueDate,
    this.expirationDate,
    this.credentialId,
    this.credentialUrl,
    required this.userId, // Add userId to constructor
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'],
      name: json['name'],
      issuingOrganization: json['issuingOrganization'],
      issueDate: DateTime.parse(json['issueDate']),
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'])
          : null,
      credentialId: json['credentialId'],
      credentialUrl: json['credentialUrl'],
      userId: json['userId'], // Add userId to fromJson
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'issuingOrganization': issuingOrganization,
      'issueDate': issueDate.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'credentialId': credentialId,
      'credentialUrl': credentialUrl,
      'userId': userId, // Add userId to toJson
    };
  }
}
