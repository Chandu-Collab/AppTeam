import 'package:flutter/material.dart';
import 'package:taurusai/models/chat.dart';
import 'package:taurusai/screens/chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final List<Chat> chats = [
    // Dummy data, replace with actual chat data
    Chat(
      id: '1',
      participantIds: ['user1', 'user2'],
      messages: [
        Message(
          id: '1',
          senderId: 'user1',
          content: 'Hello',
          timestamp: DateTime.now().subtract(Duration(days: 1)),
          type: MessageType.text,
          imageUrl: '',
          videoUrl: '',
          attachmentUrl: '',
        ),
      ],
    ),
    // Add more dummy chats here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          final lastMessage = chat.messages.last;
          return ListTile(
            leading: CircleAvatar(
              child: Text(chat.participantIds[1][0].toUpperCase()),
            ),
            title:
                Text(chat.participantIds[1]), // Replace with actual user name
            subtitle: Text(lastMessage.content),
            trailing: Text(
              '${lastMessage.timestamp.hour}:${lastMessage.timestamp.minute}',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(chat: chat),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
