import 'package:flutter/material.dart';
import 'package:taurusai/models/course.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/services/course_service.dart';
import 'package:taurusai/widgets/input_widget.dart';

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
  List<String> category=[];
  List<String> skill = [];
  String instructorUrl = '';
  double price=0;
  String url = '';
  // final TextEditingController idController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController instructorUrlController = TextEditingController();
  final TextEditingController topicsController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController courseUrlController = TextEditingController();

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

  void _submitForm() 
     async {
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
                      createrId: widget.user.id, userId: '',
                    );
                    try {
                      String courseId =
                          await CourseService().createCourse(newCourse);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Course created successfully with ID: $courseId')),
                      );
                      Navigator.pop(context);
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
    double width = 0;
    isMobile ? width = 300 : width = 746;
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
                    
                    buildTextField( "Title", titleController,(value) {}, (value) => title, icon: Icons.title),
                    isMobile
                        ? SizedBox(
                            width: 300, // Adjust width dynamically if needed
                            child: TextFormField(
                              maxLines: 4, // Allows multi-line input
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                labelText: "Description",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                              ),
                              validator: (value) => value!.isEmpty
                                  ? "Description is required"
                                  : null,
                            ),
                          )
                        : SizedBox(
                            width: 630, // Adjust width dynamically if needed
                            child: TextFormField(
                              maxLines: 4, // Allows multi-line input
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                labelText: "Description",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                              ),
                              validator: (value) => value!.isEmpty
                                  ? "Description is required"
                                  : null,
                            ),
                          ),
                  ]),
                  SizedBox(height: 15),
                  _sectionTitle("Course Information"),
                  _buildGrid([
                    _buildDropdown("Category", categories, selectedCategory,
                        (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    }),
                    // buildTextField(skillsController, "Skills", Icons.star),
                   buildTextField("Skills", skillsController, (value) {}, (value) => skill = value!.split(',').map((s) => s.trim()).toList(),icon: Icons.star,),
                    //
                    SizedBox(height: 20),
                    // _buildTextField(instructorUrlController, "Instructor URL",
                    //     Icons.person),
                  ]),
                  SizedBox(height: 15),
                  _sectionTitle("Additional Details"),
                  _buildGrid([
                   buildTextField("Skills", topicsController, (value) {}, (value) => skill, icon: Icons.topic,),               
                  //  buildTextField(topicsController, "Topics", Icons.topic),
                    // buildTextField(
                    //     durationController, "Duration (hours)", Icons.timer),
                   buildTextField("Skills", durationController, (value) {}, (value) => skill, icon: Icons.timer,),                         
                    _buildDropdown("Level", levels, selectedLevel, (value) {
                      setState(() {
                        selectedLevel = value!;
                      });
                    }),
                  ]),
                  SizedBox(height: 15),
                  _sectionTitle("Pricing & Availability"),
                  _buildGrid([
                    buildTextField(
                         "Price",priceController, (value) {}, (value) => price, icon: Icons.attach_money,
                        isNumeric: true),
                    buildTextField(
                         "Course URL", courseUrlController, (value) {}, (value) => instructorUrl, icon:  Icons.link),
                  ]),
                  SizedBox(height: 15),
                  _buildGrid([
                    _buildDateField("Start Date", startDate,
                        () => _pickDate(context, true)),
                    _buildDateField(
                        "End Date", endDate, () => _pickDate(context, false)),
                  ]),
                  SizedBox(height: 20),
                  _buildDropdown("Status", statuses, selectedStatus, (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  }),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                  )), SizedBox(height: 40),
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
      children: children
          .map((e) => Padding(padding: EdgeInsets.all(8.0), child: e))
          .toList(),
    );
  }


  Widget _buildDropdown(String label, List<String> items, String selectedValue,
      Function(String?) onChanged) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
  return SizedBox(
    width: 300,
    child: TextFormField(
      readOnly: true,
      controller: TextEditingController(
        text: date == null ? "" : "${date.toLocal()}".split(' ')[0], // Format date
      ),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: onTap,
    ),
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
