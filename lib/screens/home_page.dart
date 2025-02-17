import 'package:flutter/material.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/screens/applications_screen.dart';
import 'package:taurusai/screens/calendar_screen.dart';
import 'package:taurusai/screens/chat_list_screen.dart';
import 'package:taurusai/screens/courses_page.dart';
import 'package:taurusai/screens/create_course_screen.dart';
import 'package:taurusai/screens/create_job_screen.dart';
import 'package:taurusai/screens/home_feed_page.dart';
import 'package:taurusai/screens/jobs_page.dart';
import 'package:taurusai/screens/network_page.dart';
import 'package:taurusai/screens/notifications_page.dart';
import 'package:taurusai/screens/post_page.dart';
import 'package:taurusai/screens/profile_page.dart';
import 'package:taurusai/screens/user_details_form.dart';
import 'package:taurusai/services/auth_service.dart';
import 'package:taurusai/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;

class HomePage extends StatefulWidget {
  final User user;

  HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  final FirebaseAuth.FirebaseAuth _auth = FirebaseAuth.FirebaseAuth.instance;
  bool? _isProfileComplete;
  late List<Widget> _children;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeChildren();
  }

  void _initializeChildren() {
    _children = [
      HomeFeedPage(user: widget.user),
      JobsPage(user: widget.user),
      PostPage(user: widget.user),
      CoursesPage(user: widget.user),
      NetworkPage(user: widget.user),
    ];
  }

  Future<void> _loadUserData() async {
    User? updatedUser = await _userService.getUser(widget.user.id);
    if (updatedUser != null) {
      setState(() {
        _isProfileComplete = updatedUser.isProfileComplete ?? false;
      });
    }
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isProfileComplete == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isProfileComplete!) {
      return UserDetailsForm(user: widget.user);
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Job Search App'),
          backgroundColor: Colors.lightBlue[300],
          leading: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(user: widget.user)),
              );
            },
            child: CircleAvatar(
              backgroundImage: widget.user.url != null
                  ? NetworkImage(widget.user.url!)
                  : AssetImage('assets/default_profile.png') as ImageProvider,
              radius: 16,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationsPage(
                            user: widget.user,
                          ))),
            ),
            IconButton(
              icon: Icon(Icons.chat),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChatListScreen())),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'Create Job':
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateJobScreen(
                                  user: widget.user,
                                )));
                    break;
                  case 'Create Course':
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => createCoursePage(
                                  user: widget.user,
                                )));
                    break;
                  case 'Applications':
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ApplicationsScreen()));
                    break;
                  case 'Calendar':
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CalendarScreen()));
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'Create Job',
                  child: Text('Create Job'),
                ),
                PopupMenuItem<String>(
                  value: 'Create Course',
                  child: Text('Create Course'),
                ),
                PopupMenuItem<String>(
                  value: 'Applications',
                  child: Text('Applications'),
                ),
                PopupMenuItem<String>(
                  value: 'Calendar',
                  child: Text('Calendar'),
                ),
              ],
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: _children,
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.lightBlue[300],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work),
              label: 'Jobs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box),
              label: 'Post',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'Courses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Network',
            ),
          ],
        ),
      ),
    );
  }
}
