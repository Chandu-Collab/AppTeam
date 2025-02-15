import 'package:flutter/material.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/services/notification_service.dart';
import 'package:taurusai/models/notification.dart' as custom;

class NotificationsPage extends StatefulWidget {
  final User user;

  NotificationsPage({required this.user});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();
  List<custom.Notification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications =
          await _notificationService.getNotificationsForUser(widget.user.id);
      setState(() {
        _notifications = notifications;
      });
    } catch (e) {
      print('Error loading notifications: $e');
      // Optionally, you can set _notifications to an empty list here
      // setState(() {
      //   _notifications = [];
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return ListTile(
            leading: CircleAvatar(
              child: Icon(_getNotificationIcon(notification.type)),
            ),
            title: Text(notification.content),
            subtitle: Text(notification.timestamp.toString()),
            trailing: notification.isRead
                ? null
                : Icon(Icons.brightness_1, color: Colors.blue, size: 12),
            onTap: () {
              _notificationService.markNotificationAsRead(notification.id);
              setState(() {
                _notifications[index] = custom.Notification(
                  id: notification.id,
                  type: notification.type,
                  content: notification.content,
                  senderId: notification.senderId,
                  recipientId: notification.recipientId,
                  timestamp: notification.timestamp,
                  isRead: true,
                );
              });
            },
          );
        },
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'job':
        return Icons.work;
      case 'course':
        return Icons.school;
      case 'post':
        return Icons.post_add;
      case 'follow':
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }
}
