import 'package:flutter/material.dart';
import 'package:taurusai/models/chat.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/screens/chat_screen.dart';
import 'package:taurusai/screens/profile_edit_page.dart';
import 'package:taurusai/services/user_service.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isFollowing = false;
  late Future<User?> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = UserService().getUser(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.lightBlue[300],
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              User? user = await userFuture;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileEditPage(user: user)),
                ).then((_) {
                  setState(() {
                    userFuture = UserService().getUser(widget.user.id);
                  });
                });
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<User?>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('User not found'));
          }

          User user = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(user),
                _buildActionButtons(user),
                _buildSection('About', user.bio ?? ''),
                _buildEducationSection(user),
                _buildExperienceSection(user),
                _buildSkillsSection(user),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.lightBlue[300],
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: user.url != null
                ? NetworkImage(user.url!)
                : AssetImage('assets/default_profile.png') as ImageProvider,
            radius: 50,
          ),
          SizedBox(height: 16),
          Text(
            user.profileName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(User user) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                isFollowing = !isFollowing;
              });
            },
            child: Text(isFollowing ? 'Unfollow' : 'Follow'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isFollowing ? Colors.grey : Colors.lightBlue[300],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _startChat(user);
            },
            child: Text('Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue[300],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationSection(User user) {
    // Implement this method to display user's education
    return Container();
  }

  Widget _buildExperienceSection(User user) {
    // Implement this method to display user's experience
    return Container();
  }

  Widget _buildSkillsSection(User user) {
    // Implement this method to display user's skills
    return Container();
  }

  void _startChat(User user) {
    // Create a new chat or navigate to an existing chat
    Chat newChat = Chat(
      id: DateTime.now().toString(),
      participantIds: ['currentUserId', user.id],
      messages: [],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chat: newChat),
      ),
    );
  }
}
