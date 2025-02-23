import 'package:flutter/material.dart';
import 'package:taurusai/widgets/input_widget.dart';

class AddJobPage extends StatefulWidget {
  @override
  _AddJobPageState createState() => _AddJobPageState();
}

class _AddJobPageState extends State<AddJobPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String company = '';
  String location = '';
  String description = '';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Job'),
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
                'Job Title',
                _titleController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a job title';
                  }
                  return null;
                },
                (value) => _titleController.text = value!,
              ),
              SizedBox(height: 16),
              buildTextField(
                'Company',
                _companyController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a company name';
                  }
                  return null;
                },
                (value) => _companyController.text = value!,
              ),
              SizedBox(height: 16),
              buildTextField(
                'Location',
                _locationController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
                (value) => _locationController.text = value!,
              ),
              SizedBox(height: 16),
              buildTextField(
                'Description',
                _descriptionController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a job description';
                  }
                  return null;
                },
                (value) => _descriptionController.text = value!,
                maxLines: 5,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                child: Text('Add Job'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[300],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // TODO: Implement job addition logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Job added successfully')),
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


// Old Code
// import 'package:flutter/material.dart';

// class AddJobPage extends StatefulWidget {
//   @override
//   _AddJobPageState createState() => _AddJobPageState();
// }

// class _AddJobPageState extends State<AddJobPage> {
//   final _formKey = GlobalKey<FormState>();
//   String title = '';
//   String company = '';
//   String location = '';
//   String description = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Job'),
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
//                   labelText: 'Job Title',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a job title';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) => title = value!,
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'Company',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a company name';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) => company = value!,
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'Location',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a location';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) => location = value!,
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
//                     return 'Please enter a job description';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) => description = value!,
//               ),
//               SizedBox(height: 24),
//               ElevatedButton(
//                 child: Text('Add Job'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.lightBlue[300],
//                   foregroundColor: Colors.white,
//                   padding: EdgeInsets.symmetric(vertical: 15),
//                 ),
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     _formKey.currentState!.save();
//                     // TODO: Implement job addition logic
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Job added successfully')),
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
