import 'package:flutter/material.dart';
import 'package:taurusai/models/course.dart';
import 'package:taurusai/models/topic.dart';
import 'package:taurusai/services/course_service.dart';

class CourseContentScreen extends StatefulWidget {
  final String courseId;

  CourseContentScreen({required this.courseId});

  @override
  _CourseContentScreenState createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen> {
  final CourseService _courseService = CourseService();

  late Future<Course?> _courseFuture;

  @override
  void initState() {
    super.initState();
    _courseFuture = _courseService.getCourse(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Content'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: FutureBuilder<Course?>(
        future: _courseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Course not found'));
          } else {
            Course course = snapshot.data!;
            return ListView(
              children: [
                _buildCourseHeader(course),
                _buildTopicsList(course.topics),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildCourseHeader(Course course) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          LinearProgressIndicator(
            value: 0.5, // Replace with actual progress
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 8),
          Text('50% Complete'), // Replace with actual progress
        ],
      ),
    );
  }

  Widget _buildTopicsList(List<Topic> topics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Topics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: topics.length,
          itemBuilder: (context, index) {
            Topic topic = topics[index];
            return ListTile(
              title: Text(topic.name),
              subtitle: Text(topic.description),
              onTap: () {
                // Navigate to topic content
              },
            );
          },
        ),
      ],
    );
  }
}
