import 'dart:io';
import 'package:flutter/material.dart';
import 'package:taurusai/widgets/input_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class AddCareerBreakScreen extends StatefulWidget {
  /// [initialData] holds the stored fields for editing.
  /// [experienceId] is the Firestore document ID to update (if editing).
  final Map<String, dynamic>? initialData;
  final String? experienceId;

  const AddCareerBreakScreen({Key? key, this.initialData, this.experienceId})
      : super(key: key);

  @override
  _AddCareerBreakScreenState createState() => _AddCareerBreakScreenState();
}

class _AddCareerBreakScreenState extends State<AddCareerBreakScreen> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Career break type dropdown.
  String? careerBreakType;
  final List<String> careerBreakTypes = [
    'Bereavement',
    'Career transition',
    'Care giving',
    'Full time parenting',
    'Gap year',
    'Layoff/Position eliminated',
    'Health and well-being',
    'Personal goal pursuit',
    'Professional development',
    'Relocation',
    'Retirement',
    'Travel and voluntary work',
  ];

  // Checkbox for currently on break.
  bool currentlyOnBreak = false;

  // Start Date dropdowns.
  String? startMonth;
  String? startYear;
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  late final List<String> years = List.generate(
      30, (index) => (DateTime.now().year - index).toString());

  // End Date dropdowns.
  String? endMonth;
  String? endYear;

  // Media files.
  List<File> mediaFiles = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      careerBreakType = widget.initialData!['careerBreakType'];
      locationController.text = widget.initialData!['location'] ?? "";
      descriptionController.text = widget.initialData!['description'] ?? "";
      currentlyOnBreak = widget.initialData!['currentlyOnBreak'] ?? false;
      startMonth = widget.initialData!['startMonth'];
      startYear = widget.initialData!['startYear'];
      if (!currentlyOnBreak) {
        endMonth = widget.initialData!['endMonth'];
        endYear = widget.initialData!['endYear'];
      }
      List<dynamic>? mediaPaths = widget.initialData!['mediaFiles'];
      if (mediaPaths != null) {
        mediaFiles = mediaPaths.map((e) => File(e.toString())).toList();
      }
    }
  }

  /// Allows the user to pick a media file.
  Future<void> pickMedia() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['jpg', 'jpeg', 'pdf', 'doc', 'docx'],
      type: FileType.custom,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        mediaFiles.add(File(result.files.single.path!));
      });
    }
  }

  /// Saves (or updates) the career break details in Firestore.
  Future<void> save() async {
    String? userId = getCurrentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in. Please login again.')),
      );
      return;
    }

    Map<String, dynamic> data = {
      'careerBreakType': careerBreakType,
      'location': locationController.text,
      'currentlyOnBreak': currentlyOnBreak,
      'startMonth': startMonth,
      'startYear': startYear,
      'endMonth': currentlyOnBreak ? null : endMonth,
      'endYear': currentlyOnBreak ? null : endYear,
      'description': descriptionController.text,
      'mediaFiles': mediaFiles.map((f) => f.path).toList(),
      'type': 'career_break',
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      // Updated Firestore path using the current user's ID.
      if (widget.experienceId != null) {
        await FirebaseFirestore.instance
            .collection('taurusai')
            .doc('users')
            .collection(userId)
            .doc('experiences')
            .collection('positions')
            .doc(widget.experienceId)
            .update(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Career break updated successfully')),
        );
      } else {
        await FirebaseFirestore.instance
            .collection('taurusai')
            .doc('users')
            .collection(userId)
            .doc('experiences')
            .collection('positions')
            .add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Career break added successfully')),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  /// Gets the current user’s UID from FirebaseAuth.
  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Career Break')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Career Break Type Dropdown.
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              value: careerBreakType,
              hint: const Text('Select Career Break Type'),
              items: careerBreakTypes
                  .map((type) => DropdownMenuItem(
                        child: Text(type),
                        value: type,
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  careerBreakType = val;
                });
              },
            ),
            const SizedBox(height: 16),
            // Location.
            buildTextField(
              'Location',
              locationController,
              (value) => value!.isEmpty ? 'Required' : null,
              (value) {},
            ),
            const SizedBox(height: 16),
            // Currently on break checkbox.
            Row(
              children: [
                Checkbox(
                  value: currentlyOnBreak,
                  onChanged: (val) {
                    setState(() {
                      currentlyOnBreak = val!;
                    });
                  },
                ),
                const Text('I am currently on this career break'),
              ],
            ),
            const SizedBox(height: 16),
            // Start Date.
            const Text(
              'Start Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                    value: startMonth,
                    hint: const Text('Select Month'),
                    items: months
                        .map((m) =>
                            DropdownMenuItem(child: Text(m), value: m))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        startMonth = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                    value: startYear,
                    hint: const Text('Select Year'),
                    items: years
                        .map((y) =>
                            DropdownMenuItem(child: Text(y), value: y))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        startYear = val;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // End Date.
            const Text(
              'End Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                    value: endMonth,
                    hint: const Text('Select Month'),
                    items: months
                        .map((m) =>
                            DropdownMenuItem(child: Text(m), value: m))
                        .toList(),
                    onChanged: currentlyOnBreak
                        ? null
                        : (val) {
                            setState(() {
                              endMonth = val;
                            });
                          },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                    value: endYear,
                    hint: const Text('Select Year'),
                    items: years
                        .map((y) =>
                            DropdownMenuItem(child: Text(y), value: y))
                        .toList(),
                    onChanged: currentlyOnBreak
                        ? null
                        : (val) {
                            setState(() {
                              endYear = val;
                            });
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Description.
            buildTextField(
              'Description',
              descriptionController,
              null,
              (value) {},
            ),
            const SizedBox(height: 16),
            // Media Section.
            const Text(
              'Media',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Center(
              child: IconButton(
                icon: const Icon(Icons.add_circle, size: 36),
                onPressed: pickMedia,
              ),
            ),
            const SizedBox(height: 8),
            if (mediaFiles.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mediaFiles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(mediaFiles[index].path.split('/').last),
                  );
                },
              ),
            const SizedBox(height: 24),
            // Save Button using custom buildButton widget.
            Center(
              child: buildButton(save, text: 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom button widget.
Widget buildButton(onPressedMethod, {String? text}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minimumSize: Size(double.infinity, 50),
    ),
    onPressed: onPressedMethod,
    child: Text(
      text ?? "Save",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  );
}
