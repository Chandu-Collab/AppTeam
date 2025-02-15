import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ResumeUploadWidget extends StatefulWidget {
  const ResumeUploadWidget({Key? key}) : super(key: key);

  @override
  _ResumeUploadWidgetState createState() => _ResumeUploadWidgetState();
}

class _ResumeUploadWidgetState extends State<ResumeUploadWidget> {
  String? _fileName;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
      });
      // TODO: Implement file upload logic
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload Resume'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ),
        if (_fileName != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Uploaded: $_fileName'),
          ),
      ],
    );
  }
}
