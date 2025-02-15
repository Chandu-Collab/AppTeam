import 'package:flutter/material.dart';
import 'package:taurusai/models/job.dart';
import 'package:taurusai/services/job_service.dart';
import 'package:taurusai/widgets/job_card.dart';

class HomePage1 extends StatelessWidget {
  final JobService _jobService = JobService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: FutureBuilder<List<Job>>(
        future: _jobService.getAllJobs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Job> jobs = snapshot.data ?? [];
            return ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                return JobCard(job: jobs[index]);
              },
            );
          }
        },
      ),
    );
  }
}
