import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/notification.dart';
import 'package:taurusai/services/notification_service.dart';

class FollowService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _followsCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('followers')
      .collection('Follower');
  final NotificationService _notificationService = NotificationService();

  Future<void> followUser(String followerId, String followedId) async {
    await _followsCollection.add({
      'followerId': followerId,
      'followedId': followedId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    Notification newNotification = Notification(
      id: '',
      type: 'follow',
      content: 'Someone started following you',
      senderId: followerId,
      recipientId: followedId,
      timestamp: DateTime.now(),
    );
    await _notificationService.createNotification(newNotification);
  }

  Future<void> unfollowUser(String followerId, String followedId) async {
    QuerySnapshot snapshot = await _followsCollection
        .where('followerId', isEqualTo: followerId)
        .where('followedId', isEqualTo: followedId)
        .get();

    for (DocumentSnapshot doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<bool> isFollowing(String followerId, String followedId) async {
    QuerySnapshot snapshot = await _followsCollection
        .where('followerId', isEqualTo: followerId)
        .where('followedId', isEqualTo: followedId)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<List<String>> getFollowers(String userId) async {
    QuerySnapshot snapshot =
        await _followsCollection.where('followedId', isEqualTo: userId).get();

    return snapshot.docs.map((doc) => doc['followerId'] as String).toList();
  }

  Future<List<String>> getFollowing(String userId) async {
    QuerySnapshot snapshot =
        await _followsCollection.where('followerId', isEqualTo: userId).get();

    return snapshot.docs.map((doc) => doc['followedId'] as String).toList();
  }

  Stream<List<String>> followerStream(String userId) {
    return _followsCollection
        .where('followedId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc['followerId'] as String).toList());
  }

  Stream<List<String>> followingStream(String userId) {
    return _followsCollection
        .where('followerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc['followedId'] as String).toList());
  }

  Future<List<String>> getFollowedUsers(String userId) async {
    QuerySnapshot snapshot =
        await _followsCollection.where('followerId', isEqualTo: userId).get();

    return snapshot.docs.map((doc) => doc['followedId'] as String).toList();
  }
}
