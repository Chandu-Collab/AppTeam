import 'package:flutter/material.dart';
import 'package:taurusai/widgets/input_widget.dart';

class AddCoursePage extends StatefulWidget {
  @override
  _AddCoursePageState createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String instructor = '';
  String description = '';
  String duration = '';
  String level = '';
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _instructorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Course'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildTextField(
                'Course Title',
                _titleController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course title';
                  }
                  return null;
                },
                (value) => _titleController.text = value!,
              ),
              SizedBox(height: 16),
              buildTextField(
                'Instructor',
                _instructorController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an instructor name';
                  }
                  return null;
                },
                (value) => _instructorController.text = value!,
              ),
              SizedBox(height: 16),
              buildTextField(
                'Description',
                _descriptionController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course description';
                  }
                  return null;
                },
                (value) => _descriptionController.text = value!,
                maxLines: 5,
              ),
              SizedBox(height: 16),
              buildTextField(
                'Duration',
                _durationController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the course duration';
                  }
                  return null;
                },
                (value) => _durationController.text = value!,
              ),
              SizedBox(height: 16),
              buildTextField(
                'Level',
                _levelController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the course level';
                  }
                  return null;
                },
                (value) => _levelController.text = value!,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                child: Text('Add Course'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[300],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // TODO: Implement course addition logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Course added successfully')),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Old code 
// import 'package:flutter/material.dart';

// class AddCoursePage extends StatefulWidget {
//   @override
//   _AddCoursePageState createState() => _AddCoursePageState();
// }

// class _AddCoursePageState extends State<AddCoursePage> {
  // final _formKey = GlobalKey<FormState>();
  // String title = '';
  // String instructor = '';
  // String description = '';
  // String duration = '';
  // String level = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Course'),
//         backgroundColor: Colors.lightBlue[300],
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'Course Title',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a course title';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) => title = value!,
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'Instructor',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter an instructor name';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) => instructor = value!,
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'Description',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 5,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a course description';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) => description = value!,
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'Duration',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the course duration';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) => duration = value!,
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'Level',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the course level';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) => level = value!,
//               ),
//               SizedBox(height: 24),
//               ElevatedButton(
//                 child: Text('Add Course'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.lightBlue[300],
//                   foregroundColor: Colors.white,
//                   padding: EdgeInsets.symmetric(vertical: 15),
//                 ),
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     _formKey.currentState!.save();
//                     // TODO: Implement course addition logic
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Course added successfully')),
//                     );
//                     Navigator.pop(context);
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
