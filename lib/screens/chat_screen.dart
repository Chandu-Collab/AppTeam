import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:taurusai/models/chat.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({Key? key, required this.chat}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.participantIds[1]),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chat.id)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final message = snapshot.data!.docs[index];
                    return MessageBubble(
                      message: Message(
                        id: message.id,
                        senderId: message['senderId'],
                        content: message['content'],
                        timestamp: (message['timestamp'] as Timestamp).toDate(),
                        type: MessageType.text,
                        imageUrl: message['imageUrl'] ?? '',
                        videoUrl: message['videoUrl'] ?? '',
                        attachmentUrl: message['attachmentUrl'] ?? '',
                      ),
                      isMe: message['senderId'] == 'user1',
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAttachmentOptions,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration.collapsed(
                hintText: 'Send a message...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                _sendMessage(_messageController.text);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Document'),
              onTap: () async {
                final result = await FilePicker.platform.pickFiles();
                if (result != null && result.files.isNotEmpty) {
                  if (kIsWeb) {
                    final bytes = result.files.first.bytes;
                    if (bytes != null) {
                      await _uploadFile(fileBytes: bytes, folder: 'documents');
                    }
                  } else {
                    if (result.files.single.path != null) {
                      await _uploadFile(
                        filePath: result.files.single.path,
                        folder: 'documents',
                      );
                    }
                  }
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                final pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                );
                if (pickedFile != null) {
                  if (kIsWeb) {
                    final bytes = await pickedFile.readAsBytes();
                    await _uploadFile(fileBytes: bytes, folder: 'images');
                  } else {
                    await _uploadFile(
                      filePath: pickedFile.path,
                      folder: 'images',
                    );
                  }
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Media'),
              onTap: () async {
                final pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (pickedFile != null) {
                  if (kIsWeb) {
                    final bytes = await pickedFile.readAsBytes();
                    await _uploadFile(fileBytes: bytes, folder: 'images');
                  } else {
                    await _uploadFile(
                      filePath: pickedFile.path,
                      folder: 'images',
                    );
                  }
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadFile({
    String? filePath,
    Uint8List? fileBytes,
    required String folder,
  }) async {
    try {
      final ref =
          _storage.ref().child('$folder/${DateTime.now().toIso8601String()}');
      if (kIsWeb) {
        if (fileBytes != null) {
          await ref.putData(fileBytes);
        }
      } else {
        if (filePath != null) {
          await ref.putFile(File(filePath));
        }
      }
      final downloadUrl = await ref.getDownloadURL();
      _sendMessage(downloadUrl);
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  void _sendMessage(String content) {
    _firestore
        .collection('chats')
        .doc(widget.chat.id)
        .collection('messages')
        .add({
      'senderId': 'user1',
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'imageUrl': '',
      'videoUrl': '',
      'attachmentUrl': '',
    }).catchError((error) => print('Failed to send message: $error'));

    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: isMe ? Colors.lightBlue[300] : Colors.grey[300],
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
