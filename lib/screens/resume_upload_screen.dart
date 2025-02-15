import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/screens/home_page.dart';
import 'package:taurusai/services/user_service.dart';
import 'dart:io';

class ResumeUploadScreen extends StatefulWidget {
  final User user;

  ResumeUploadScreen({required this.user});

  @override
  _ResumeUploadScreenState createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends State<ResumeUploadScreen> {
  final UserService _userService = UserService();
  File? _file;
  bool isLoading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Resume')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              child: Text('Select Resume'),
              onPressed: _pickFile,
            ),
            SizedBox(height: 20),
            if (_file != null)
              Text('Selected file: ${_file!.path.split('/').last}'),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Upload and Continue'),
              onPressed: () async {
                if (_file != null) {
                  setState(() => isLoading = true);
                  try {
                    await _userService.uploadResume(widget.user.id, _file!);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(
                                user: widget.user,
                              )),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error uploading resume: $e')),
                    );
                  }
                  setState(() => isLoading = false);
                }
              },
            ),
            SizedBox(height: 20),
            TextButton(
              child: Text('Skip for now'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage(
                            user: widget.user,
                          )),
                );
              },
            ),
            if (isLoading) Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
