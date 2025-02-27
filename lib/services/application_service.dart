import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/application.dart';

class ApplicationService {
  final CollectionReference _applicationsCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('jobs')
      .collection('applications');

  Future<Map<String, dynamic>> createApplication(
      Application application) async {
    try {
      // Check if an application with the same jobId and userId already exists
      QuerySnapshot existingApplications = await _applicationsCollection
          .where('jobId', isEqualTo: application.jobId)
          .where('userId', isEqualTo: application.userId)
          .get();

      if (existingApplications.docs.isNotEmpty) {
        return {
          'success': false,
          'message': 'Application already exists for this job and user.',
        };
      }

      // If no existing application is found, create the new application
      DocumentReference docRef =
          await _applicationsCollection.add(application.toJson());
      return {
        'success': true,
        'applicationId': docRef.id,
        'message': 'Application created successfully.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating application: $e',
      };
    }
  }

  Future<Application?> getApplication(String applicationId) async {
    DocumentSnapshot doc =
        await _applicationsCollection.doc(applicationId).get();
    return doc.exists
        ? Application.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  Future<List<Application>> getApplicationsForUser(String userId) async {
    QuerySnapshot snapshot =
        await _applicationsCollection.where('userId', isEqualTo: userId).get();
    return snapshot.docs
        .map((doc) => Application.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Application>> getApplicationsForJob(String jobId) async {
    QuerySnapshot snapshot =
        await _applicationsCollection.where('jobId', isEqualTo: jobId).get();
    return snapshot.docs
        .map((doc) => Application.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Application>> getUserApplications(String jobId) async {
    QuerySnapshot snapshot =
        await _applicationsCollection.where('jobId', isEqualTo: jobId).get();
    return snapshot.docs
        .map((doc) => Application.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateApplication(Application application) async {
    await _applicationsCollection
        .doc(application.id)
        .update(application.toJson());
  }

  Future<void> deleteApplication(String applicationId) async {
    await _applicationsCollection.doc(applicationId).delete();
  }
}
