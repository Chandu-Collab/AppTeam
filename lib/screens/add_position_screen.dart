import 'dart:io';
import 'package:flutter/material.dart';
import 'package:taurusai/widgets/input_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// The provided date field widget.
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

class AddPositionScreen extends StatefulWidget {
  /// [initialData] holds the stored fields for editing.
  /// [experienceId] is the Firestore document ID to update (if editing).
  final Map<String, dynamic>? initialData;
  final String? experienceId;

  const AddPositionScreen({Key? key, this.initialData, this.experienceId})
      : super(key: key);

  @override
  _AddPositionScreenState createState() => _AddPositionScreenState();
}

class _AddPositionScreenState extends State<AddPositionScreen> {
  // Controllers for text fields.
  final TextEditingController titleController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Controllers for date fields.
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  // Dropdown variables.
  String? employmentType;
  final List<String> employmentTypes = [
    'Full-time',
    'Part-Time',
    'Self employed',
    'Free lance',
    'Internship',
    'Trainee',
  ];

  // Checkbox for current role.
  bool currentlyWorking = false;

  // Location type dropdown.
  String? locationType;
  final List<String> locationTypes = ['Hybrid', 'On-site', 'Remote'];

  // Job source dropdown.
  String? jobSource;
  final List<String> jobSources = [
    'LinkedIn',
    'Naukari',
    'Indeed',
    'Company website',
    'Other job sites',
    'Referral',
    'Contacted by recruiter',
    'Staffing agency',
    'Other'
  ];

  // Media files.
  List<File> mediaFiles = [];

  @override
  void initState() {
    super.initState();
    // If initialData is provided, pre-populate all fields.
    if (widget.initialData != null) {
      titleController.text = widget.initialData!['title'] ?? "";
      companyController.text = widget.initialData!['company'] ?? "";
      locationController.text = widget.initialData!['location'] ?? "";
      descriptionController.text = widget.initialData!['description'] ?? "";
      employmentType = widget.initialData!['employmentType'];
      currentlyWorking = widget.initialData!['currentlyWorking'] ?? false;
      
      // If startMonth and startYear exist, construct a start date.
      if (widget.initialData!['startMonth'] != null &&
          widget.initialData!['startYear'] != null) {
        // Assuming day = 1 for simplicity.
        startDate = DateTime(
          int.parse(widget.initialData!['startYear'].toString()),
          _monthNumber(widget.initialData!['startMonth'].toString()),
        );
        startDateController.text =
            "${widget.initialData!['startMonth']} ${widget.initialData!['startYear']}";
      }
      
      if (!currentlyWorking &&
          widget.initialData!['endMonth'] != null &&
          widget.initialData!['endYear'] != null) {
        endDate = DateTime(
          int.parse(widget.initialData!['endYear'].toString()),
          _monthNumber(widget.initialData!['endMonth'].toString()),
        );
        endDateController.text =
            "${widget.initialData!['endMonth']} ${widget.initialData!['endYear']}";
      }
      locationType = widget.initialData!['locationType'];
      jobSource = widget.initialData!['jobSource'];
      List<dynamic>? mediaPaths = widget.initialData!['mediaFiles'];
      if (mediaPaths != null) {
        mediaFiles = mediaPaths.map((e) => File(e.toString())).toList();
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    companyController.dispose();
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

  /// Opens the date picker for start date.
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

  /// Opens the date picker for end date.
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

  /// Saves (or updates) the experience in Firestore.
  Future<void> save() async {
    String? userId = getCurrentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in. Please login again.')),
      );
      return;
    }

    Map<String, dynamic> data = {
      'title': titleController.text,
      'employmentType': employmentType,
      'company': companyController.text,
      'currentlyWorking': currentlyWorking,
      // Save start date details if available.
      'startMonth': startDate != null ? _monthName(startDate!.month) : null,
      'startYear': startDate != null ? startDate!.year.toString() : null,
      // Save end date details only if not currently working.
      'endMonth': (!currentlyWorking && endDate != null)
          ? _monthName(endDate!.month)
          : null,
      'endYear': (!currentlyWorking && endDate != null)
          ? endDate!.year.toString()
          : null,
      'location': locationController.text,
      'locationType': locationType,
      'description': descriptionController.text,
      'jobSource': jobSource,
      'mediaFiles': mediaFiles.map((f) => f.path).toList(),
      'type': 'position',
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.experienceId != null) {
        // Update existing document.
        await FirebaseFirestore.instance
            .collection('taurusai')
            .doc('users')
            .collection(userId)
            .doc('experiences')
            .collection('positions')
            .doc(widget.experienceId)
            .update(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Experience updated successfully')),
        );
      } else {
        // Add new document.
        await FirebaseFirestore.instance
            .collection('taurusai')
            .doc('users')
            .collection(userId)
            .doc('experiences')
            .collection('positions')
            .add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Experience added successfully')),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  /// Returns the current user's UID from FirebaseAuth.
  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Position')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            buildTextField(
              'Title',
              titleController,
              (value) => value!.isEmpty ? 'Required' : null,
              (value) {},
            ),
            SizedBox(height: 16),
            // Employment Type Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Employment Type',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              value: employmentType,
              hint: const Text('Select Employment Type'),
              items: employmentTypes
                  .map((type) => DropdownMenuItem(
                        child: Text(type),
                        value: type,
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  employmentType = val;
                });
              },
            ),
            SizedBox(height: 16),
            // Company or Organization
            buildTextField(
              'Company or Organization',
              companyController,
              (value) => value!.isEmpty ? 'Required' : null,
              (value) {},
            ),
            SizedBox(height: 16),
            // Currently working checkbox.
            Row(
              children: [
                Checkbox(
                  value: currentlyWorking,
                  onChanged: (val) {
                    setState(() {
                      currentlyWorking = val!;
                    });
                  },
                ),
                const Text('I am currently working in this role'),
              ],
            ),
            SizedBox(height: 16),
            // Start Date using buildDateField.
            const Text(
              'Start Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            buildDateField("Select Start Date", startDateController, _pickStartDate),
            SizedBox(height: 16),
            // End Date using buildDateField (only if not currently working).
            if (!currentlyWorking) ...[
              const Text(
                'End Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildDateField("Select End Date", endDateController, _pickEndDate),
              SizedBox(height: 16),
            ],
            // Location
            buildTextField(
              'Location',
              locationController,
              (value) => value!.isEmpty ? 'Required' : null,
              (value) {},
            ),
            SizedBox(height: 16),
            // Location Type Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Location Type',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              value: locationType,
              hint: const Text('Select Location Type'),
              items: locationTypes
                  .map((type) => DropdownMenuItem(
                        child: Text(type),
                        value: type,
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  locationType = val;
                });
              },
            ),
            SizedBox(height: 16),
            // Description
            buildTextField(
              'Description',
              descriptionController,
              null,
              (value) {},
            ),
            SizedBox(height: 16),
            // Job Source Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Where did you find this job?',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              value: jobSource,
              hint: const Text('Select Job Source'),
              items: jobSources
                  .map((source) => DropdownMenuItem(
                        child: Text(source),
                        value: source,
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  jobSource = val;
                });
              },
            ),
            SizedBox(height: 16),
            // Media Section.
            const Text(
              'Media',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add_circle,
                      size: 36, color: Colors.orange),
                  onPressed: pickMedia,
                ),
              ),
            ),
            SizedBox(height: 8),
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
            SizedBox(height: 24),
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
