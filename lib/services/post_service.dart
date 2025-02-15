import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/comment.dart';
import 'package:taurusai/models/notification.dart';
import 'package:taurusai/models/post.dart';
import 'package:taurusai/services/notification_service.dart';

class PostService {
  final CollectionReference _postsCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('posts')
      .collection('postsItem');
  final CollectionReference _commentsCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('posts')
      .collection('comments');
  Future<String> createPost(Post post) async {
    DocumentReference docRef = await _postsCollection.add(post.toJson());
    return docRef.id;
  }

  Future<Post?> getPost(String postId) async {
    DocumentSnapshot doc = await _postsCollection.doc(postId).get();
    return doc.exists
        ? Post.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  Future<List<Post>> getAllPosts() async {
    QuerySnapshot snapshot = await _postsCollection.get();
    return snapshot.docs
        .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updatePost(Post post) async {
    await _postsCollection.doc(post.postid).update(post.toJson());
  }

  Future<void> deletePost(String postId) async {
    await _postsCollection.doc(postId).delete();
  }

  Future<void> createPostWithNotification(Post post) async {
    String postId = await createPost(post);

    NotificationService notificationService = NotificationService();
    Notification notification = Notification(
      id: '',
      type: 'post',
      content: '${post.username} created a new post',
      senderId: post.userId,
      recipientId:
          'all', // You might want to implement a way to notify relevant users
      timestamp: DateTime.now(),
    );
    await notificationService.createNotification(notification);
  }

  Future<String> addComment(Comment comment) async {
    DocumentReference docRef = await _commentsCollection.add(comment.toJson());
    await _postsCollection
        .doc(comment.postId)
        .update({'commentCount': FieldValue.increment(1)});
    return docRef.id;
  }

  Future<List<Comment>> getCommentsForPost(String postId) async {
    QuerySnapshot snapshot = await _commentsCollection
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Comment.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> likePost(String postId, String userId) async {
    await _postsCollection.doc(postId).update({
      'likes': FieldValue.arrayUnion([userId])
    });
  }

  Future<void> unlikePost(String postId, String userId) async {
    await _postsCollection.doc(postId).update({
      'likes': FieldValue.arrayRemove([userId])
    });
  }

  Stream<Post> postStream(String postId) {
    return _postsCollection
        .doc(postId)
        .snapshots()
        .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>));
  }
}
