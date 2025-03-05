import 'dart:io';
import 'package:flutter/material.dart';
import 'package:taurusai/widgets/input_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Custom dropdown widget updated to accept nullable value.
Widget buildDropdown<T>({
  required String label,
  T? value,
  required List<T> items,
  required void Function(T?) onChanged,
  String? Function(T?)? validator,
}) {
  return SizedBox(
    width: 300,
    child: DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(item.toString()),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    ),
  );
}

/// Provided date field widget.
Widget buildDateField(
  String label,
  TextEditingController controller,
  VoidCallback onTap, {
  String? Function(String?)? validator,
}) {
  return SizedBox(
    width: 300,
    child: TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: Icon(Icons.calendar_today),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      validator: validator,
      onTap: onTap,
    ),
  );
}

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

  // Date controllers and variables.
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

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
      // Initialize start date if data exists.
      if (widget.initialData!['startMonth'] != null &&
          widget.initialData!['startYear'] != null) {
        startDate = DateTime(
          int.parse(widget.initialData!['startYear'].toString()),
          _monthNumber(widget.initialData!['startMonth'].toString()),
        );
        startDateController.text =
            "${widget.initialData!['startMonth']} ${widget.initialData!['startYear']}";
      }
      // Initialize end date if not currently on break.
      if (!currentlyOnBreak &&
          widget.initialData!['endMonth'] != null &&
          widget.initialData!['endYear'] != null) {
        endDate = DateTime(
          int.parse(widget.initialData!['endYear'].toString()),
          _monthNumber(widget.initialData!['endMonth'].toString()),
        );
        endDateController.text =
            "${widget.initialData!['endMonth']} ${widget.initialData!['endYear']}";
      }
      List<dynamic>? mediaPaths = widget.initialData!['mediaFiles'];
      if (mediaPaths != null) {
        mediaFiles = mediaPaths.map((e) => File(e.toString())).toList();
      }
    }
  }

  @override
  void dispose() {
    locationController.dispose();
    descriptionController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  /// Helper: Convert month name to month number.
  int _monthNumber(String monthName) {
    const monthNames = [
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
    return monthNames.indexOf(monthName) + 1;
  }

  /// Helper: Convert month number to month name.
  String _monthName(int month) {
    const monthNames = [
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
    return monthNames[month - 1];
  }

  /// Opens the date picker for the start date.
  Future<void> _pickStartDate() async {
    DateTime initial = startDate ?? DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        startDateController.text = "${_monthName(picked.month)} ${picked.year}";
      });
    }
  }

  /// Opens the date picker for the end date.
  Future<void> _pickEndDate() async {
    DateTime initial = endDate ?? DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
        endDateController.text = "${_monthName(picked.month)} ${picked.year}";
      });
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
      // Save start date details.
      'startMonth': startDate != null ? _monthName(startDate!.month) : null,
      'startYear': startDate != null ? startDate!.year.toString() : null,
      // Save end date details only if not currently on break.
      'endMonth': (!currentlyOnBreak && endDate != null)
          ? _monthName(endDate!.month)
          : null,
      'endYear': (!currentlyOnBreak && endDate != null)
          ? endDate!.year.toString()
          : null,
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
            // Career Break Type Dropdown using buildDropdown.
            buildDropdown<String>(
              label: 'Type',
              value: careerBreakType,
              items: careerBreakTypes,
              onChanged: (val) {
                setState(() {
                  careerBreakType = val;
                });
              },
              validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
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
            // Start Date using buildDateField.
            const Text(
              'Start Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            buildDateField("Select Start Date", startDateController, _pickStartDate),
            const SizedBox(height: 16),
            // End Date using buildDateField (only if not currently on break).
            if (!currentlyOnBreak) ...[
              const Text(
                'End Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildDateField("Select End Date", endDateController, _pickEndDate),
              const SizedBox(height: 16),
            ],
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
