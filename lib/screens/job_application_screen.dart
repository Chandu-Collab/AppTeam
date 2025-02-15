import 'package:flutter/material.dart';
import 'package:taurusai/models/application.dart';
import 'package:taurusai/models/job.dart';
import 'package:taurusai/services/application_service.dart';
import 'package:taurusai/widgets/resume_upload_widget.dart';

class JobApplicationScreen extends StatefulWidget {
  final Job job;

  JobApplicationScreen({required this.job});

  @override
  _JobApplicationScreenState createState() => _JobApplicationScreenState();
}

class _JobApplicationScreenState extends State<JobApplicationScreen> {
  final ApplicationService _applicationService = ApplicationService();
  final _formKey = GlobalKey<FormState>();
  String coverLetter = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for Job'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.job.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                widget.job.company,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Cover Letter'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a cover letter' : null,
                onSaved: (value) => coverLetter = value!,
                maxLines: 5,
              ),
              SizedBox(height: 16),
              ResumeUploadWidget(),
              SizedBox(height: 24),
              ElevatedButton(
                child: Text('Submit Application'),
                onPressed: _submitApplication,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Application newApplication = Application(
        id: '',
        userId: 'currentUserId', // Replace with actual user ID
        jobId: widget.job.id,
        portfolio: coverLetter,
        status: 'Pending',
        jobTitle: widget.job.title,
        jobswipeStatus: '',
        chnageDate: DateTime.now(),
        applicationDate: DateTime.now(),
      );
      await _applicationService.createApplication(newApplication);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application submitted successfully')),
      );
      Navigator.pop(context);
    }
  }
}
