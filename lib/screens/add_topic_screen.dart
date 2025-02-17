import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:taurusai/models/topic.dart';
import 'package:taurusai/services/topic_service.dart';

class AddTopicScreen extends StatefulWidget {
  final String courseId;

  AddTopicScreen({required this.courseId});

  @override
  _AddTopicScreenState createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends State<AddTopicScreen>
    with SingleTickerProviderStateMixin {
  final TopicService _topicService = TopicService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _instructorController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _topicCountController = TextEditingController();
  final List<String> _questions = [""];

  bool _isDescriptionExpanded = false;
  String? _attachmentPath;

  int? _numberOfTopics;
  int _currentTopicIndex = 0;
  List<Topic> _topics = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _attachmentPath = result.files.single.path;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Topic newTopic = Topic(
        id: '',
        name: _nameController.text,
        description: _descriptionController.text,
        instructor: _instructorController.text,
        studyVideoUrl: _videoUrlController.text,
        attachment: _attachmentPath,
        title: _titleController.text,
        question: _questions,
      );

      _topics.add(newTopic);

      if (_currentTopicIndex < _numberOfTopics! - 1) {
        setState(() {
          _currentTopicIndex++;
          _clearForm();
        });
      } else {
        _saveAllTopics();
      }
    }
  }

  void _saveAllTopics() async {
    try {
      for (var topic in _topics) {
        String topicId = await _topicService.createTopic(topic);
        await _topicService.addTopicToCourse(widget.courseId, topicId);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_topics.length} topics added successfully')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding topics: $e')),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _titleController.clear();
    _descriptionController.clear();
    _instructorController.clear();
    _videoUrlController.clear();
    _questions.clear();
    _questions.add("");
    setState(() {
      _attachmentPath = null;
    });
  }

  void _startTopicCreation() {
    if (_topicCountController.text.isNotEmpty) {
      int? numberOfTopics = int.tryParse(_topicCountController.text);
      if (numberOfTopics != null && numberOfTopics > 0) {
        setState(() {
          _numberOfTopics = numberOfTopics;
          _currentTopicIndex = 0;
          _topics.clear();
          _animationController.forward();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Topic'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _topicCountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Number of Topics',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _startTopicCreation,
              child: Text('Start Adding Topics'),
            ),
            SizedBox(height: 20),
            _numberOfTopics != null
                ? FadeTransition(
                    opacity: _fadeAnimation,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(labelText: 'Name'),
                                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                              ),
                              TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(labelText: 'Title'),
                                validator: (value) => value!.isEmpty ? 'Enter your title' : null,
                              ),
                              TextFormField(
                                controller: _instructorController,
                                decoration:
                                    InputDecoration(labelText: 'Instructor'),
                                    validator: (value) => value!.isEmpty ? 'Enter your Instructor' : null,
                              ),
                              TextFormField(
                                controller: _videoUrlController,
                                decoration: InputDecoration(
                                    labelText: 'Study Video URL'),
                                    validator: (value) => value!.isEmpty ? 'Enter your Study Video URL' : null,
                              ),
                              GestureDetector(
                                onTap: _pickFile,
                                child: Row(
                                  children: [
                                    Icon(Icons.attach_file),
                                    SizedBox(width: 8),
                                    Text(_attachmentPath ?? 'Attach a file'),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Description'),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        _isDescriptionExpanded =
                                            !_isDescriptionExpanded;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              if (_isDescriptionExpanded)
                                TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder()),
                                ),
                              Column(
                                children: _questions.map((q) {
                                  return TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Question',
                                      border: OutlineInputBorder(),
                                    ),
                                  );
                                }).toList(),
                              ),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    _questions.add("");
                                  });
                                },
                              ),
                              ElevatedButton(
                                onPressed: _submitForm,
                                child: Text(
                                    _currentTopicIndex < _numberOfTopics! - 1
                                        ? 'Next Topic'
                                        : 'Save All Topics'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
