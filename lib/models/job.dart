class Job {
  final String id;
  final String title;
  final String company;
  final String jobType;
  final String description;
  final String experienceLevel;
  final String? salaryRange;
  final List<String> responsbilities;
  final List<String> requirements;
  final List<String> benefits;
  final List<String> skills;
  final String? location;
  final String? email;
  final String companyLogo;
  final String postedDate;
  final String status;
  final String? userId; // Add userId field

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.jobType,
    required this.description,
    required this.experienceLevel,
    this.salaryRange,
    required this.responsbilities,
    required this.requirements,
    required this.benefits,
    required this.skills,
    this.location,
    this.email,
    required this.companyLogo,
    required this.postedDate,
    required this.status,
    required this.userId, // Add userId to constructor
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'],
      company: json['company'],
      jobType: json['jobType'],
      description: json['description'],
      experienceLevel: json['experienceLevel'],
      salaryRange: json['salaryRange'],
      responsbilities: List<String>.from(json['responsbilities']),
      requirements: List<String>.from(json['requirements']),
      benefits: List<String>.from(json['benefits']),
      skills: List<String>.from(json['skills']),
      location: json['location'],
      email: json['email'],
      companyLogo: json['companyLogo'],
      postedDate: json['postedDate'],
      status: json['status'],
      userId: json['userId'], // Add userId to fromJson
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'jobType': jobType,
      'description': description,
      'experienceLevel': experienceLevel,
      'salaryRange': salaryRange,
      'responsbilities': responsbilities,
      'requirements': requirements,
      'benefits': benefits,
      'skills': skills,
      'location': location,
      'email': email,
      'companyLogo': companyLogo,
      'postedDate': postedDate,
      'status': status,
      'userId': userId, // Add userId to toJson
    };
  }
}
