import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/course.dart';
import 'package:taurusai/models/notification.dart';
import 'package:taurusai/models/topic.dart';
import 'package:taurusai/services/notification_service.dart';

class CourseService {
  final CollectionReference _coursesCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('courses')
      .collection('listings');
  final CollectionReference _topicsCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('courses')
      .collection('topics');

  Future<String> createCourse(Course course) async {
    DocumentReference docRef = await _coursesCollection.add(course.toJson());
    return docRef.id;
  }

  Future<Course?> getCourse(String courseId) async {
    DocumentSnapshot doc = await _coursesCollection.doc(courseId).get();
    return doc.exists
        ? Course.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  Future<List<Course>> getAllCourses() async {
    QuerySnapshot snapshot = await _coursesCollection.get();
    return snapshot.docs
        .map((doc) => Course.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateCourse(Course course) async {
    await _coursesCollection.doc(course.id).update(course.toJson());
  }

  Future<void> deleteCourse(String courseId) async {
    await _coursesCollection.doc(courseId).delete();
  }

  Future<List<Topic>> getTopicsForCourse(String courseId) async {
    DocumentSnapshot courseDoc = await _coursesCollection.doc(courseId).get();
    List<String> topicIds = List<String>.from(courseDoc['topics'] ?? []);

    List<Topic> topics = [];
    for (String topicId in topicIds) {
      DocumentSnapshot topicDoc = await _topicsCollection.doc(topicId).get();
      topics.add(Topic.fromJson(topicDoc.data() as Map<String, dynamic>));
    }

    return topics;
  }

  Future<String> createTopic(Topic topic) async {
    DocumentReference docRef = await _topicsCollection.add(topic.toJson());
    return docRef.id;
  }

  Future<void> addTopicToCourse(String courseId, String topicId) async {
    await _coursesCollection.doc(courseId).update({
      'topics': FieldValue.arrayUnion([topicId])
    });
  }

  Future<void> createCourseWithNotification(
      Course course, String creatorId) async {
    String courseId = await createCourse(course);

    NotificationService notificationService = NotificationService();
    Notification notification = Notification(
      id: '',
      type: 'course',
      content: 'New course available: ${course.title}',
      senderId: creatorId,
      recipientId:
          'all', // You might want to implement a way to notify relevant users
      timestamp: DateTime.now(),
    );
    await notificationService.createNotification(notification);
  }
}
