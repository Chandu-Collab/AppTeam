import 'package:flutter/material.dart';
import 'package:taurusai/models/chat.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  ChatScreen({required this.chat});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.chat.participantIds[1]), // Replace with actual user name
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.chat.messages.length,
              itemBuilder: (context, index) {
                final message = widget.chat.messages[index];
                return MessageBubble(
                  message: message,
                  isMe: message.senderId ==
                      'user1', // Replace with actual current user ID
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
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAttachmentOptions,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration.collapsed(
                hintText: 'Send a message...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
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
      builder: (context) => Wrap(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.insert_drive_file),
            title: Text('Document'),
            onTap: () {
              // Handle document selection
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Camera'),
            onTap: () {
              // Handle camera selection
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo),
            title: Text('Media'),
            onTap: () {
              // Handle media selection
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.gif),
            title: Text('GIF'),
            onTap: () {
              // Handle GIF selection
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.alternate_email),
            title: Text('Mention'),
            onTap: () {
              // Handle mention
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Location'),
            onTap: () {
              // Handle location selection
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(String content) {
    setState(() {
      widget.chat.messages.add(Message(
        id: DateTime.now().toString(),
        senderId: 'user1', // Replace with actual current user ID
        content: content,
        timestamp: DateTime.now(),
        type: MessageType.text,
        imageUrl: '',
        videoUrl: '',
        attachmentUrl: '',
      ));
    });
    _messageController.clear();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
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
                SizedBox(height: 4.0),
                Text(
                  '${message.timestamp.hour}:${message.timestamp.minute}',
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.black54,
                    fontSize: 12.0,
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
