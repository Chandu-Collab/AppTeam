import 'package:flutter/material.dart';
import 'package:taurusai/models/admission.dart';
import 'package:taurusai/models/application.dart';
import 'package:taurusai/services/application_service.dart';
import 'package:taurusai/services/enrollment_service.dart';

class UserActivitiesScreen extends StatefulWidget {
  @override
  _UserActivitiesScreenState createState() => _UserActivitiesScreenState();
}

class _UserActivitiesScreenState extends State<UserActivitiesScreen> {
  final ApplicationService _applicationService = ApplicationService();
  final EnrollmentService _enrollmentService = EnrollmentService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Activities'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Applied Jobs'),
              Tab(text: 'Enrolled Courses'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAppliedJobsList(),
            _buildEnrolledCoursesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppliedJobsList() {
    return FutureBuilder<List<Application>>(
      future: _applicationService
          .getUserApplications('currentUserId'), // Replace with actual user ID
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No applied jobs'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Application application = snapshot.data![index];
              return ListTile(
                title: Text('Job ID: ${application.jobId}'),
                subtitle: Text('Status: ${application.status}'),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildEnrolledCoursesList() {
    return FutureBuilder<List<Admission>>(
      future: _enrollmentService
          .getUserEnrollments('currentUserId'), // Replace with actual user ID
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No enrolled courses'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Admission admission = snapshot.data![index];
              return ListTile(
                title: Text('Course ID: ${admission.courseId}'),
                subtitle: Text(
                    'Enrolled: ${admission.admissionDate.toString().split(' ')[0]}'),
              );
            },
          );
        }
      },
    );
  }
}
