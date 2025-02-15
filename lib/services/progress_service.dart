import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/progress.dart';

class ProgressService {
  final CollectionReference _progressCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('courses')
      .collection('progress');

  Future<void> createOrUpdateProgress(Progress progress) async {
    await _progressCollection
        .doc('${progress.userId}_${progress.courseId}')
        .set(
          progress.toJson(),
          SetOptions(merge: true),
        );
  }

  Future<Progress?> getProgress(String userId, String courseId) async {
    DocumentSnapshot doc =
        await _progressCollection.doc('${userId}_${courseId}').get();
    return doc.exists
        ? Progress.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  Future<List<Progress>> getUserProgress(String userId) async {
    QuerySnapshot snapshot =
        await _progressCollection.where('userId', isEqualTo: userId).get();
    return snapshot.docs
        .map((doc) => Progress.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateProgress(Progress progress) async {
    await _progressCollection
        .doc('${progress.userId}_${progress.courseId}')
        .update(progress.toJson());
  }
}
