import 'package:flutter/material.dart';
import 'package:taurusai/models/job.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/services/job_service.dart';
import 'package:taurusai/widgets/input_widget.dart'; // Import the buildTextField function

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

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _jobTypeController = TextEditingController();
  final TextEditingController _experienceLevelController = TextEditingController();
  final TextEditingController _salaryRangeController = TextEditingController();
  final TextEditingController _responsibilitiesController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _benefitsController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyLogoController = TextEditingController();

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
              buildTextField(
                'Job Title',
                _titleController,
                (value) => value!.isEmpty ? 'Please enter a job title' : null,
                (value) => title = value!,
              ),
              SizedBox(height: 16),
              buildTextField(
                'Company',
                _companyController,
                (value) => value!.isEmpty ? 'Please enter a company name' : null,
                (value) => company = value!,
              ),
              SizedBox(height: 16),
              buildTextField(
                'Location',
                _locationController,
                (value) => value!.isEmpty ? 'Please enter a location' : null,
                (value) => location = value!,
              ),
              SizedBox(height: 16),
              buildTextField(
                'Description',
                _descriptionController,
                (value) => value!.isEmpty ? 'Please enter a job description' : null,
                (value) => description = value!,
                maxLines: 5,
              ),
              SizedBox(height: 16),
              buildTextField(
                'Job Type',
                _jobTypeController,
                null,
                (value) => jobType = value!,
              ),
              SizedBox(height: 16),
              buildTextField(
                'Experience Level',
                _experienceLevelController,
                null,
                (value) => experienceLevel = value!,
              ),
              SizedBox(height: 16),
              buildTextField(
                'Salary Range',
                _salaryRangeController,
                null,
                (value) => salaryRange = value!,
              ),
              SizedBox(height: 16),
              buildTextField(
                'Responsibilities (comma-separated)',
                _responsibilitiesController,
                null,
                (value) => responsibilities = value!.split(','),
              ),
              SizedBox(height: 16),
              buildTextField(
                'Requirements (comma-separated)',
                _requirementsController,
                null,
                (value) => requirements = value!.split(','),
              ),
              SizedBox(height: 16),
              buildTextField(
                'Benefits (comma-separated)',
                _benefitsController,
                null,
                (value) => benefits = value!.split(','),
              ),
              SizedBox(height: 16),
              buildTextField(
                'Skills (comma-separated)',
                _skillsController,
                null,
                (value) => skills = value!.split(','),
              ),
              SizedBox(height: 16),
              buildTextField(
                'Email',
                _emailController,
                null,
                (value) => email = value!,
              ),
              SizedBox(height: 16),
              buildTextField(
                'Company Logo URL',
                _companyLogoController,
                (value) => value!.isEmpty ? 'Please enter a company logo URL' : null,
                (value) => companyLogo = value!,
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