import 'package:flutter/material.dart';
import 'package:taurusai/models/application.dart';
import 'package:taurusai/models/job.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/services/application_service.dart';
import 'package:taurusai/services/auth_service.dart';
import 'package:taurusai/services/job_service.dart';

class JobDetailsPage extends StatelessWidget {
  final Job job;

  JobDetailsPage({required this.job});

  @override
  final ApplicationService _applicationService = ApplicationService();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Details'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              job.company,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Text(
              'Location: ${job.location}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Description:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              job.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Posted: ${job.postedDate}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _applyForJob(context),
              child: Text('Apply Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[300],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyForJob(BuildContext context) async {
    final ApplicationService _applicationService = ApplicationService();
    User? currentUser = await AuthService().getCurrentUser();
    try {
      Application newApplication = Application(
          id: '',
          userId: currentUser!.id,
          portfolioUrl: currentUser.url,
          portfolio: currentUser.bio,
          chnageDate: DateTime.now(),
          jobId: job.id,
          status: 'Pending',
          jobTitle: job.title,
          applicationDate: DateTime.now(),
          jobswipeStatus: 'NEW');
      await _applicationService.createApplication(newApplication);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting application: $e')),
      );
    }
  }
}
