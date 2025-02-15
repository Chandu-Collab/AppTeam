import 'package:flutter/material.dart';
import 'package:taurusai/models/admission.dart';
import 'package:taurusai/models/course.dart';
import 'package:taurusai/services/enrollment_service.dart';

class CourseEnrollmentScreen extends StatelessWidget {
  final Course course;
  final EnrollmentService _enrollmentService = EnrollmentService();

  CourseEnrollmentScreen({required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enroll in Course'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              course.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              'Instructor: ${course.instructorUrl}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            Text(
              course.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Text(
              'Duration: ${course.duration}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Level: ${course.level}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Price: \$${course.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              child: Text('Enroll Now'),
              onPressed: () => _enrollInCourse(context),
            ),
          ],
        ),
      ),
    );
  }

  void _enrollInCourse(BuildContext context) async {
    Admission newAdmission = Admission(
      id: '',
      userId: 'currentUserId', // Replace with actual user ID
      courseId: course.id,
      admissionDate: DateTime.now(),
      status: '',
      admUserurl: 'currentUserName', // Replace with actual user name
      courseName: course.title,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
    );
    await _enrollmentService.createEnrollment(newAdmission);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Enrolled in course successfully')),
    );
    Navigator.pop(context);
  }
}
