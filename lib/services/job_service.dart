import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/job.dart';
import 'package:taurusai/models/notification.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/services/notification_service.dart';

class JobService {
  final CollectionReference _jobsCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('jobs')
      .collection('listings');

  Future<String> createJob(Job job) async {
    DocumentReference docRef = await _jobsCollection.add(job.toJson());
    return docRef.id;
  }

  Future<Job?> getJob(String jobId) async {
    DocumentSnapshot doc = await _jobsCollection.doc(jobId).get();
    return doc.exists ? Job.fromJson(doc.data() as Map<String, dynamic>) : null;
  }

  Future<List<Job>> getAllJobs() async {
    QuerySnapshot snapshot = await _jobsCollection.get();
    return snapshot.docs
        .map((doc) => Job.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateJob(Job job) async {
    await _jobsCollection.doc(job.id).update(job.toJson());
  }

  Future<void> deleteJob(String jobId) async {
    await _jobsCollection.doc(jobId).delete();
  }

  Future<List<Job>> searchJobs(String query) async {
    QuerySnapshot snapshot = await _jobsCollection
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: query + 'z')
        .get();
    return snapshot.docs
        .map((doc) => Job.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Job>> getRecentJobs(
      {int limit = 10, DocumentSnapshot? startAfter}) async {
    Query query =
        _jobsCollection.orderBy('postedDate', descending: true).limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    QuerySnapshot snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Job.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> createJobWithNotification(Job job, String creatorId) async {
    String jobId = await createJob(job);

    NotificationService notificationService = NotificationService();
    Notification notification = Notification(
      id: '',
      type: 'job',
      content: 'New job posted: ${job.title}',
      senderId: creatorId,
      recipientId:
          'all', // You might want to implement a way to notify relevant users
      timestamp: DateTime.now(),
    );
    await notificationService.createNotification(notification);
  }
}
