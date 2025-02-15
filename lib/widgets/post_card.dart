import 'package:flutter/material.dart';
import 'package:taurusai/models/comment.dart';
import 'package:taurusai/models/post.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/services/auth_service.dart';
import 'package:taurusai/services/post_service.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PostService _postService = PostService();
  bool isLiked = false;
  int likeCount = 0;
  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    likeCount = widget.post.likes;
  }

  Future<void> _toggleLike() async {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
    User? currentUser = await AuthService().getCurrentUser();
    _postService.likePost(widget.post.postid, currentUser!.id);
  }

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      User? currentUser = await AuthService().getCurrentUser();
      Comment newComment = Comment(
        id: '',
        userId: currentUser!.id,
        postId: widget.post.postid,
        content: _commentController.text,
        createdAt: DateTime.now(),
        userUrl: currentUser.url,
        likes: 0,
      );
      _postService.addComment(newComment);
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment added successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.post.userProfileUrl),
                  radius: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.username,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.post.createdAt.toString(),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(widget.post.content),
            SizedBox(height: 12),
            if (widget.post.url != null)
              Image.network(
                widget.post.url!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                      ),
                      onPressed: _toggleLike,
                    ),
                    Text('$likeCount'),
                  ],
                ),
                Text(widget.post.location),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addComment,
                  child: Text('Post'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
