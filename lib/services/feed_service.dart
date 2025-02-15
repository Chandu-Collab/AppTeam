import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/feed.dart';

class FeedService {
  final CollectionReference _feedCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('feeds')
      .collection('feedItem');

  Future<String> createFeedItem(Feed feedItem) async {
    DocumentReference docRef = await _feedCollection.add(feedItem.toJson());
    return docRef.id;
  }

  Future<List<Feed>> getFeedForUser(String userId) async {
    QuerySnapshot snapshot = await _feedCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Feed.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteFeedItem(String feedId) async {
    await _feedCollection.doc(feedId).delete();
  }

  Stream<List<Feed>> feedStream(String userId) {
    return _feedCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Feed.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
}
