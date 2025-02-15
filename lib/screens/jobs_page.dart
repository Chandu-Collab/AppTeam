import 'package:flutter/material.dart';
import 'package:taurusai/models/job.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/screens/job_details_page.dart';
import 'package:taurusai/services/job_service.dart';
import 'package:taurusai/widgets/swipeable_job_card.dart';

class JobsPage extends StatefulWidget {
  final User user;

  JobsPage({required this.user});

  @override
  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final JobService _jobService = JobService();
  List<Job> jobs = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Job> loadedJobs = await _jobService.getAllJobs();
      setState(() {
        jobs = loadedJobs;
      });
    } catch (e) {
      print('Error loading jobs: $e');
      // Use test data if service fails
      setState(() {
        jobs = [
          Job(
            id: '1',
            title: 'Software Engineer',
            company: 'Tech Co',
            jobType: 'Full-time',
            description:
                'We are looking for a talented software engineer to join our team...',
            experienceLevel: 'Mid-level',
            salaryRange: '\$80,000 - \$120,000',
            responsbilities: [
              'Develop high-quality software',
              'Collaborate with cross-functional teams'
            ],
            requirements: [
              'Bachelor\'s degree in Computer Science',
              '3+ years of experience in software development'
            ],
            benefits: [
              'Health insurance',
              '401(k) matching',
              'Flexible work hours'
            ],
            skills: ['Java', 'Python', 'JavaScript'],
            location: 'San Francisco, CA',
            email: 'jobs@techco.com',
            companyLogo: 'https://placeholder.svg?height=100&width=100',
            postedDate: '2023-07-01',
            status: 'Open',
          ),
          // Add more test jobs here
        ];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jobs'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : jobs.isNotEmpty
              ? Stack(
                  children: jobs.asMap().entries.map((entry) {
                    int idx = entry.key;
                    Job job = entry.value;
                    return Positioned.fill(
                      child: SwipeableJobCard(
                        job: job,
                        onSwipeLeft: () => _handleSwipe(idx, false),
                        onSwipeRight: () => _handleSwipe(idx, true),
                        onSwipeUp: () => _handleSuperLike(idx),
                        onTap: () => _viewJobDetails(job),
                      ),
                    );
                  }).toList(),
                )
              : Center(
                  child: Text('No more jobs available'),
                ),
    );
  }

  void _handleSwipe(int index, bool isLiked) {
    setState(() {
      jobs.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isLiked ? 'Job application sent!' : 'Job skipped'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleSuperLike(int index) {
    setState(() {
      jobs.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Super liked! Application sent with high priority.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _viewJobDetails(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailsPage(job: job),
      ),
    );
  }
}
