import 'experience.dart';
import 'education.dart';
import 'dependent.dart';
import 'social.dart';
import 'certificate.dart';
import 'address.dart';
import 'course.dart';
import 'progress.dart';

class Profile {
  final String userId;
  final String handle;
  final String? company;
  final String? website;
  final String? location;
  final String status;
  final List<String> skills;
  final String? bio;
  final String? githubUsername;
  final List<Experience> experience;
  final List<Education> education;
  final List<Dependent> dependents;
  final Social social;
  final DateTime date;
  final List<Certificate> certificates;
  final List<Address> addresses;
  final List<Course> enrolledCourses;
  final List<Progress> courseProgress;

  Profile({
    required this.userId,
    required this.handle,
    this.company,
    this.website,
    this.location,
    required this.status,
    required this.skills,
    this.bio,
    this.githubUsername,
    required this.experience,
    required this.education,
    required this.dependents,
    required this.social,
    required this.date,
    required this.certificates,
    required this.addresses,
    required this.enrolledCourses,
    required this.courseProgress,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: json['userId'],
      handle: json['handle'],
      company: json['company'],
      website: json['website'],
      location: json['location'],
      status: json['status'],
      skills: List<String>.from(json['skills']),
      bio: json['bio'],
      githubUsername: json['githubUsername'],
      experience: (json['experience'] as List)
          .map((e) => Experience.fromJson(e))
          .toList(),
      education: (json['education'] as List)
          .map((e) => Education.fromJson(e))
          .toList(),
      dependents: (json['dependents'] as List)
          .map((e) => Dependent.fromJson(e))
          .toList(),
      social: Social.fromJson(json['social']),
      date: DateTime.parse(json['date']),
      certificates: (json['certificates'] as List)
          .map((c) => Certificate.fromJson(c))
          .toList(),
      addresses:
          (json['addresses'] as List).map((a) => Address.fromJson(a)).toList(),
      enrolledCourses: (json['enrolledCourses'] as List)
          .map((c) => Course.fromJson(c))
          .toList(),
      courseProgress: (json['courseProgress'] as List)
          .map((p) => Progress.fromJson(p))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'handle': handle,
      'company': company,
      'website': website,
      'location': location,
      'status': status,
      'skills': skills,
      'bio': bio,
      'githubUsername': githubUsername,
      'experience': experience.map((e) => e.toJson()).toList(),
      'education': education.map((e) => e.toJson()).toList(),
      'dependents': dependents.map((e) => e.toJson()).toList(),
      'social': social.toJson(),
      'date': date.toIso8601String(),
      'certificates': certificates.map((c) => c.toJson()).toList(),
      'addresses': addresses.map((a) => a.toJson()).toList(),
      'enrolledCourses': enrolledCourses.map((c) => c.toJson()).toList(),
      'courseProgress': courseProgress.map((p) => p.toJson()).toList(),
    };
  }
}
