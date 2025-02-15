import 'package:flutter/material.dart';
import 'package:taurusai/models/application.dart';
import 'package:taurusai/services/application_service.dart';

class ApplicationsScreen extends StatefulWidget {
  @override
  _ApplicationsScreenState createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final ApplicationService _applicationService = ApplicationService();
  List<Application> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    try {
      // Replace 'currentUserId' with the actual current user's ID
      List<Application> applications =
          await _applicationService.getUserApplications('currentUserId');
      setState(() {
        _applications = applications;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading applications: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Applications'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _applications.length,
              itemBuilder: (context, index) {
                Application application = _applications[index];
                return ListTile(
                  title: Text(application.jobTitle ?? 'Unknown Job'),
                  subtitle: Text('Status: ${application.status}'),
                  trailing: Text(application.applicationDate?.toString() ??
                      'Unknown Date'),
                  onTap: () {
                    // Navigate to application details screen
                  },
                );
              },
            ),
    );
  }
}
