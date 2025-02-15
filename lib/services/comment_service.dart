import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/comment.dart';

class CommentService {
  final CollectionReference _commentsCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('posts')
      .collection('comments');

  Future<String> createComment(Comment comment) async {
    DocumentReference docRef = await _commentsCollection.add(comment.toJson());
    return docRef.id;
  }

  Future<Comment?> getComment(String commentId) async {
    DocumentSnapshot doc = await _commentsCollection.doc(commentId).get();
    return doc.exists
        ? Comment.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  Future<List<Comment>> getCommentsForPost(String postId) async {
    QuerySnapshot snapshot =
        await _commentsCollection.where('postId', isEqualTo: postId).get();
    return snapshot.docs
        .map((doc) => Comment.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateComment(Comment comment) async {
    await _commentsCollection.doc(comment.id).update(comment.toJson());
  }

  Future<void> deleteComment(String commentId) async {
    await _commentsCollection.doc(commentId).delete();
  }
}
