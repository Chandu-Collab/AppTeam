import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/notification.dart';

class NotificationService {
  final CollectionReference _notificationsCollection = FirebaseFirestore
      .instance
      .collection('taurusai')
      .doc('notifications')
      .collection('notificationItem');
  Future<String> createNotification(Notification notification) async {
    DocumentReference docRef =
        await _notificationsCollection.add(notification.toJson());
    return docRef.id;
  }

  Future<List<Notification>> getNotificationsForUser(String userId) async {
    QuerySnapshot snapshot = await _notificationsCollection
        .where('recipientId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Notification.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({'isRead': true});
  }

  Future<void> deleteNotification(String notificationId) async {
    await _notificationsCollection.doc(notificationId).delete();
  }

  Stream<List<Notification>> notificationStream(String userId) {
    return _notificationsCollection
        .where('recipientId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Notification.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
}
