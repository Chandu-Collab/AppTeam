import 'package:flutter/material.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/services/follow_service.dart';
import 'package:taurusai/services/user_service.dart';
import 'package:taurusai/widgets/user_card.dart';

class NetworkPage extends StatefulWidget {
  final User user;

  NetworkPage({required this.user});

  @override
  _NetworkPageState createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  final UserService _userService = UserService();
  final FollowService _followService = FollowService();
  List<User> _users = [];
  Set<String> _followedUsers = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadFollowedUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _userService.getAllUsers();
      setState(() {
        _users = users.where((u) => u.id != widget.user.id).toList();
      });
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Future<void> _loadFollowedUsers() async {
    try {
      final followedUsers =
          await _followService.getFollowedUsers(widget.user.id);
      setState(() {
        _followedUsers = Set.from(followedUsers);
      });
    } catch (e) {
      print('Error loading followed users: $e');
    }
  }

  Future<void> _toggleFollow(User user) async {
    try {
      if (_followedUsers.contains(user.id)) {
        await _followService.unfollowUser(widget.user.id, user.id);
        setState(() {
          _followedUsers.remove(user.id);
        });
      } else {
        await _followService.followUser(widget.user.id, user.id);
        setState(() {
          _followedUsers.add(user.id);
        });
      }
    } catch (e) {
      print('Error toggling follow: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Network'),
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final isFollowing = _followedUsers.contains(user.id);
          return UserCard(
            user: user,
            // isFollowing: isFollowing,
            onFollowPressed: () => _toggleFollow(user),
          );
        },
      ),
    );
  }
}
