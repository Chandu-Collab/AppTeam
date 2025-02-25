import 'dart:io';
import 'package:flutter/material.dart';
import 'package:taurusai/widgets/input_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Dropdown variables.
  // Removed default values so that user must select manually.
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

  // Start date dropdowns.
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

  // End date dropdowns.
  String? endMonth;
  String? endYear;

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
      startMonth = widget.initialData!['startMonth'];
      startYear = widget.initialData!['startYear'];
      if (!currentlyWorking) {
        endMonth = widget.initialData!['endMonth'];
        endYear = widget.initialData!['endYear'];
      }
      locationType = widget.initialData!['locationType'];
      jobSource = widget.initialData!['jobSource'];
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

  /// Saves (or updates) the experience in Firestore.
  Future<void> save() async {
    String? userId = getCurrentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in. Please login again.')));
      return;
    }

    Map<String, dynamic> data = {
      'title': titleController.text,
      'employmentType': employmentType,
      'company': companyController.text,
      'currentlyWorking': currentlyWorking,
      'startMonth': startMonth,
      'startYear': startYear,
      'endMonth': currentlyWorking ? null : endMonth,
      'endYear': currentlyWorking ? null : endYear,
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
            .collection('users')
            .doc(userId)
            .collection('experiences')
            .doc(widget.experienceId)
            .update(data);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Experience updated successfully')));
      } else {
        // Add new document.
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('experiences')
            .add(data);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Experience added successfully')));
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  /// Dummy function – replace with your auth logic.
  String? getCurrentUserId() {
    return "dummyUserId";
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
            // Start Date: Month and Year
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
            // End Date: Month and Year (disabled if currently working)
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
                    onChanged: currentlyWorking
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
                    onChanged: currentlyWorking
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
            // Location
            buildTextField(
              'Location',
              locationController,
              (value) => value!.isEmpty ? 'Required' : null,
              (value) {},
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            // Description
            buildTextField(
              'Description',
              descriptionController,
              null,
              (value) {},
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
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
