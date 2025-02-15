import 'package:flutter/material.dart';
import 'package:taurusai/models/admission.dart';
import 'package:taurusai/models/course.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/services/admission_service.dart';
import 'package:taurusai/services/course_service.dart';
import 'package:taurusai/widgets/course_card.dart';

class CoursesPage extends StatefulWidget {
  final User user;

  CoursesPage({required this.user});

  @override
  _CoursesPageState createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final CourseService _courseService = CourseService();
  List<Course> courses = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Course> loadedCourses = await _courseService.getAllCourses();
      setState(() {
        courses = loadedCourses;
      });
    } catch (e) {
      print('Error loading courses: $e');
      // Use test data if service fails
      setState(() {
        courses = [
          Course(
            id: '1',
            title: 'Flutter Development',
            description:
                'Learn to build beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.',
            category: ['Mobile Development', 'Cross-platform'],
            skill: ['Dart', 'Flutter'],
            instructorUrl: 'https://placeholder.svg?height=100&width=100',
            topics: [],
            duration: '10 weeks',
            level: 'Intermediate',
            price: 99.99,
            url: 'https://example.com/flutter-course',
            status: 'Open',
            createrId: widget.user.id,
          ),
          // Add more test courses here
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
        title: Text('Courses'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                return CourseCard(
                  course: courses[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailsPage(
                            course: courses[index], user: widget.user),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class CourseDetailsPage extends StatelessWidget {
  final Course course;
  final User user;

  CourseDetailsPage({required this.course, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              course.url,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16),
            Text(
              course.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              'Instructor: ${course.instructorUrl}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              'Duration: ${course.duration}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              'Level: ${course.level}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              'Price: \$${course.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            Text(
              'Description:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(course.description),
            SizedBox(height: 16),
            Text(
              'Skills:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: course.skill
                  .map((skill) => Chip(label: Text(skill)))
                  .toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Enroll Now'),
              onPressed: () => _enrollInCourse(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enrollInCourse(BuildContext context) async {
    final AdmissionService _admissionService = AdmissionService();
    try {
      Admission newAdmission = Admission(
        id: '',
        userId: user.id,
        status: 'Pending',
        courseId: course.id,
        courseName: course.title,
        admUserurl: user.url!,
        admissionDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 30)),
      );
      await _admissionService.createAdmission(newAdmission);
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
