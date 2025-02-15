import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/chat.dart';

class ChatService {
  final CollectionReference _chatsCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('users')
      .collection('chats');

  Future<String> createChat(Chat chat) async {
    DocumentReference docRef = await _chatsCollection.add(chat.toJson());
    return docRef.id;
  }

  Future<Chat?> getChat(String chatId) async {
    DocumentSnapshot doc = await _chatsCollection.doc(chatId).get();
    return doc.exists
        ? Chat.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  Future<List<Chat>> getChatsForUser(String userId) async {
    QuerySnapshot snapshot = await _chatsCollection
        .where('participantIds', arrayContains: userId)
        .get();
    return snapshot.docs
        .map((doc) => Chat.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addMessage(String chatId, Message message) async {
    await _chatsCollection.doc(chatId).update({
      'messages': FieldValue.arrayUnion([message.toJson()])
    });
  }

  Future<void> deleteChat(String chatId) async {
    await _chatsCollection.doc(chatId).delete();
  }
}
