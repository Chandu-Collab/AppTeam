import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taurusai/models/post.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/services/post_service.dart';
import 'package:taurusai/services/user_service.dart';
import 'package:taurusai/widgets/input_widget.dart'; // Import the buildTextField function

class PostPage extends StatefulWidget {
  final User user;

  PostPage({required this.user});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _contentController = TextEditingController();
  final PostService _postService = PostService();
  String? _imagePath;
  String? _videoPath;
  String? _documentPath;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoPath = pickedFile.path;
      });
    }
  }

  Future<void> _pickDocument() async {
    // Implement document picking logic here
    // You may need to use a package like file_picker for this
  }

  Future<void> _createPost() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter some content for your post')),
      );
      return;
    }

    try {
      final newPost = Post(
        postid: '', // This will be set by Firestore
        userId: widget.user.id,
        content: _contentController.text,
        createdAt: DateTime.now(),
        likes: 0,
        location: 'Unknown', // You might want to get this from the device or user input
        username: widget.user.userName,
        userProfileUrl: widget.user.url ?? '',
        url: _imagePath ?? _videoPath, // You might want to upload this file and get a URL
      );

      await _postService.createPost(newPost);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post created successfully')),
      );

      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildTextField(
              'Content',
              _contentController,
              (value) => value!.isEmpty ? 'Please enter some content' : null,
              (value) => _contentController.text = value!,
              maxLines: 5,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                  label: Text('Image'),
                ),
                ElevatedButton.icon(
                  onPressed: _pickVideo,
                  icon: Icon(Icons.videocam),
                  label: Text('Video'),
                ),
                ElevatedButton.icon(
                  onPressed: _pickDocument,
                  icon: Icon(Icons.attach_file),
                  label: Text('Document'),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_imagePath != null) Text('Image selected: $_imagePath'),
            if (_videoPath != null) Text('Video selected: $_videoPath'),
            if (_documentPath != null) Text('Document selected: $_documentPath'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createPost,
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}