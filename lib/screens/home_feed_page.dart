import 'package:flutter/material.dart';
import 'package:taurusai/models/course.dart';
import 'package:taurusai/models/job.dart';
import 'package:taurusai/models/post.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/services/course_service.dart';
import 'package:taurusai/services/job_service.dart';
import 'package:taurusai/services/post_service.dart';
import 'package:taurusai/widgets/course_card.dart';
import 'package:taurusai/widgets/job_card.dart';
import 'package:taurusai/widgets/post_card.dart';

class HomeFeedPage extends StatefulWidget {
  final User user;

  HomeFeedPage({required this.user});

  @override
  _HomeFeedPageState createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  final JobService _jobService = JobService();
  final CourseService _courseService = CourseService();
  final PostService _postService = PostService();

  List<Job> _latestJobs = [];
  List<Course> _latestCourses = [];
  List<Post> _latestPosts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final jobs = await _jobService.getAllJobs();
      final courses = await _courseService.getAllCourses();
      final posts = await _postService.getAllPosts();

      setState(() {
        _latestJobs = jobs.take(5).toList();
        _latestCourses = courses.take(5).toList();
        _latestPosts = posts.take(5).toList();
      });
    } catch (e) {
      print('Error loading data: $e');
      // Handle the error, maybe show a snackbar to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building HomeFeedPage');
    print('Latest Jobs: ${_latestJobs.length}');
    print('Latest Courses: ${_latestCourses.length}');
    print('Latest Posts: ${_latestPosts.length}');

    return ListView(
      children: [
        _buildSection('Latest Jobs',
            _latestJobs.map((job) => JobCard(job: job)).toList()),
        _buildSection(
            'Latest Courses',
            _latestCourses
                .map((course) => CourseCard(course: course, onTap: () {}))
                .toList()),
        _buildSection('Latest Posts',
            _latestPosts.map((post) => PostCard(post: post)).toList()),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    print('Building section: $title with ${items.length} items');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: items.isEmpty ? 100 : 200,
          child: items.isEmpty
              ? Center(child: Text('No $title available'))
              : ListView(
                  scrollDirection: Axis.horizontal,
                  children: items,
                ),
        ),
      ],
    );
  }
}
