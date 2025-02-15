import 'package:flutter/material.dart';
import 'package:taurusai/models/job.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/services/job_service.dart';

class CreateJobScreen extends StatefulWidget {
  User user;

  CreateJobScreen({required this.user});
  @override
  _CreateJobScreenState createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final JobService _jobService = JobService();
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String company = '';
  String location = '';
  String description = '';
  String companyLogo = '';
  String jobType = '';
  String experienceLevel = '';
  String salaryRange = '';
  List<String> responsibilities = [];
  List<String> requirements = [];
  List<String> benefits = [];
  List<String> skills = [];
  String email = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Job'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Job Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a job title' : null,
                onSaved: (value) => title = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Company'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a company name' : null,
                onSaved: (value) => company = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a location' : null,
                onSaved: (value) => location = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a job description' : null,
                onSaved: (value) => description = value!,
                maxLines: 5,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Job Type'),
                onSaved: (value) => jobType = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Experience Level'),
                onSaved: (value) => experienceLevel = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Salary Range'),
                onSaved: (value) => salaryRange = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Responsibilities (comma-separated)'),
                onSaved: (value) => responsibilities = value!.split(','),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Requirements (comma-separated)'),
                onSaved: (value) => requirements = value!.split(','),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Benefits (comma-separated)'),
                onSaved: (value) => benefits = value!.split(','),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Skills (comma-separated)'),
                onSaved: (value) => skills = value!.split(','),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                onSaved: (value) => email = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Company Logo URL'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a company logo URL' : null,
                onSaved: (value) => companyLogo = value!,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                child: Text('Create Job'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Job newJob = Job(
                      id: '', // This will be set by Firestore
                      title: title,
                      company: company,
                      jobType: jobType,
                      description: description,
                      experienceLevel: experienceLevel,
                      salaryRange: salaryRange,
                      responsbilities: responsibilities,
                      requirements: requirements,
                      benefits: benefits,
                      skills: skills,
                      location: location,
                      email: email,
                      companyLogo: companyLogo,
                      postedDate: DateTime.now().toIso8601String(),
                      status: 'Open',
                    );
                    try {
                      String jobId = await JobService().createJob(newJob);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Job created successfully with ID: $jobId')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating job: $e')),
                      );
                    }
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
