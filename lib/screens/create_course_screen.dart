import 'package:flutter/material.dart';
import 'package:taurusai/models/course.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/services/course_service.dart';
import 'package:taurusai/screens/add_topic_screen.dart';
import 'package:taurusai/widgets/input_widget.dart';
import 'package:taurusai/widgets/dropdown_widget.dart';
import 'package:taurusai/widgets/date_widget.dart'; // Import the date widget

class createCoursePage extends StatefulWidget {
  User user;

  createCoursePage({required this.user});
  @override
  _createCoursePageState createState() => _createCoursePageState();
}

class _createCoursePageState extends State<createCoursePage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String instructor = '';
  String description = '';
  String duration = '';
  String level = '';
  List<String> category = [];
  List<String> skill = [];
  String instructorUrl = '';
  double price = 0;
  String url = '';
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController instructorUrlController = TextEditingController();
  final TextEditingController topicsController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController courseUrlController = TextEditingController();

  bool _addTopic = false; // Default to unticked
  String selectedCategory = 'Programming';
  String selectedLevel = 'Beginner';
  String selectedStatus = 'Active';
  DateTime? startDate;
  DateTime? endDate;

  final List<String> categories = [
    'Programming',
    'Data Science',
    'AI/ML',
    'Cybersecurity',
    'Business'
  ];
  final List<String> levels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> statuses = ['Active', 'Inactive', 'Upcoming'];

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Course newCourse = Course(
        id: '', // This will be set by Firestore
        title: titleController.text,
        description: descriptionController.text,
        category: category,
        skill: skillsController.text.split(',').map((s) => s.trim()).toList(),
        instructorUrl: instructorUrlController.text,
        topics: [], // Topics will be added later
        duration: durationController.text,
        level: selectedLevel,
        price: double.tryParse(priceController.text) ?? 0.0,
        url: courseUrlController.text,
        status: selectedStatus,
        startDate: startDate,
        endDate: endDate,
        createrId: widget.user.id,
        userId: '',
      );
      try {
        String courseId = await CourseService().createCourse(newCourse);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Course created successfully with ID: $courseId')),
        );
        if (_addTopic) {
          // Navigate to the AddTopicScreen if checkbox is checked.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTopicScreen(courseId: courseId),
            ),
          );
        } else {
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating course: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 646;
    double width = isMobile ? 300 : 746;
    return Scaffold(
      appBar: AppBar(title: Text("Add New Course")),
      body: Center(
        child: SizedBox(
          width: width,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Course Details"),
                  _buildGrid([
                    buildTextField("Title", titleController, (value) {}, (value) => title, icon: Icons.title),
                    isMobile
                        ? SizedBox(
                            width: 300,
                            child: buildTextField(
                              "Description",
                              descriptionController,
                              (value) => value!.isEmpty ? "Description is required" : null,
                              (value) => descriptionController.text = value!,
                              icon: Icons.description,
                              maxLines: 4,
                            ),
                          )
                        : SizedBox(
                            width: 630,
                            child: buildTextField(
                              "Description",
                              descriptionController,
                              (value) => value!.isEmpty ? "Description is required" : null,
                              (value) => descriptionController.text = value!,
                              icon: Icons.description,
                              maxLines: 4,
                            ),
                          ),
                  ]),
                  SizedBox(height: 15),
                  _sectionTitle("Course Information"),
                  _buildGrid([
                    buildDropdown<String>(
                      label: "Category",
                      value: selectedCategory,
                      items: categories,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                    buildTextField("Skills", skillsController, (value) {}, (value) => skill = value!.split(',').map((s) => s.trim()).toList(), icon: Icons.star),
                  ]),
                  SizedBox(height: 15),
                  _sectionTitle("Additional Details"),
                  _buildGrid([
                    buildTextField("Skills", topicsController, (value) {}, (value) => skill, icon: Icons.topic),
                  ]),
                  _buildGrid([
                    buildTextField("Duration", durationController, (value) {}, (value) => skill, icon: Icons.timer),
                    buildDropdown<String>(
                      label: "Level",
                      value: selectedLevel,
                      items: levels,
                      onChanged: (value) {
                        setState(() {
                          selectedLevel = value!;
                        });
                      },
                    ),
                  ]),
                  SizedBox(height: 15),
                  _sectionTitle("Pricing & Availability"),
                  _buildGrid([
                    buildTextField("Price", priceController, (value) {}, (value) => price, icon: Icons.attach_money, isNumeric: true),
                    buildTextField("Course URL", courseUrlController, (value) {}, (value) => instructorUrl, icon: Icons.link),
                  ]),
                  SizedBox(height: 15),
                  _buildGrid([
                    buildDateField("Start Date", TextEditingController(text: startDate == null ? "" : "${startDate!.toLocal()}".split(' ')[0]), () => _pickDate(context, true)),
                    buildDateField("End Date", TextEditingController(text: endDate == null ? "" : "${endDate!.toLocal()}".split(' ')[0]), () => _pickDate(context, false)),
                  ]),
                  SizedBox(height: 20),
                  _buildGrid([
                    buildDropdown<String>(
                      label: "Status",
                      value: selectedStatus,
                      items: statuses,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                  ]),
                  SizedBox(height: 20),
                  // Checkbox for "Add Topic" (default unticked)
                  CheckboxListTile(
                    title: Text("Add Topic"),
                    value: _addTopic,
                    onChanged: (bool? value) {
                      setState(() {
                        _addTopic = value ?? false;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _submitForm();
                      },
                      icon: Icon(Icons.add, color: Colors.white),
                      label: Text("Add Course", style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<Widget> children) {
    return Wrap(
      spacing: 15,
      runSpacing: 15,
      children: children.map((e) => Padding(padding: EdgeInsets.all(8.0), child: e)).toList(),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}