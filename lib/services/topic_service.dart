import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/topic.dart';

class TopicService {
  final CollectionReference _topicsCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('courses')
      .collection('topics');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createTopic(Topic topic) async {
    DocumentReference docRef = await _topicsCollection.add(topic.toJson());
    return docRef.id;
  }

  Future<Topic?> getTopic(String topicId) async {
    DocumentSnapshot doc = await _topicsCollection.doc(topicId).get();
    return doc.exists
        ? Topic.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  Future<List<Topic>> getTopicsForCourse(String courseId) async {
    QuerySnapshot snapshot =
        await _topicsCollection.where('courseId', isEqualTo: courseId).get();
    return snapshot.docs
        .map((doc) => Topic.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Topic>> getTopicsByUserId(String userId) async {
    QuerySnapshot snapshot =
        await _topicsCollection.where('userId', isEqualTo: userId).get();
    return snapshot.docs
        .map((doc) => Topic.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateTopic(Topic topic) async {
    await _topicsCollection.doc(topic.id).update(topic.toJson());
  }

  Future<void> deleteTopic(String topicId) async {
    await _topicsCollection.doc(topicId).delete();
  }

  Future<void> addTopicToCourse(String courseId, String topicId) async {
    await _firestore
        .collection('taurusai')
        .doc('courses')
        .collection('listings')
        .doc(courseId)
        .update({
      'topics': FieldValue.arrayUnion([topicId])
    });
  }
}
