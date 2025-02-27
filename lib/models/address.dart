class Address {
  final String id;
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String? additionalInfo;
  final String userId; // Add userId field

  Address({
    required this.id,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.additionalInfo,
    required this.userId, // Add userId to constructor
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
      additionalInfo: json['additionalInfo'],
      userId: json['userId'], // Add userId to fromJson
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'additionalInfo': additionalInfo,
      'userId': userId, // Add userId to toJson
    };
  }
}
