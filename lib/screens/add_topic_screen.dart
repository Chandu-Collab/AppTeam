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
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructorController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _topicCountController = TextEditingController();
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
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => _attachmentPath = result.files.single.path);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _topics.add(Topic(
        id: '',
        name: _nameController.text,
        description: _descriptionController.text,
        instructor: _instructorController.text,
        studyVideoUrl: _videoUrlController.text,
        attachment: _attachmentPath,
        title: _titleController.text,
        question: _questions,
      ));

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${_topics.length} topics added successfully')));
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error adding topics: $e')));
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
    setState(() => _attachmentPath = null);
  }

  void _startTopicCreation() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Add Topic'), backgroundColor: Colors.blueAccent),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _topicCountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: 'Number of Topics',
                      border: OutlineInputBorder()),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                    onPressed: _startTopicCreation,
                    child: Text('Start Adding Topics')),
                SizedBox(height: 20),
                if (_numberOfTopics != null)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                  controller: _nameController,
                                  decoration:
                                      InputDecoration(labelText: 'Name')),
                              TextFormField(
                                  controller: _titleController,
                                  decoration:
                                      InputDecoration(labelText: 'Title')),
                              TextFormField(
                                  controller: _instructorController,
                                  decoration:
                                      InputDecoration(labelText: 'Instructor')),
                              TextFormField(
                                  controller: _videoUrlController,
                                  decoration: InputDecoration(
                                      labelText: 'Study Video URL')),
                              GestureDetector(
                                onTap: _pickFile,
                                child: Row(children: [
                                  Icon(Icons.attach_file),
                                  SizedBox(width: 8),
                                  Text(_attachmentPath ?? 'Attach a file')
                                ]),
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
                                children:
                                    List.generate(_questions.length, (index) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Question',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () {
                                          setState(() {
                                            _questions.add("");
                                          });
                                        },
                                      ),
                                      if (_questions.length > 1)
                                        IconButton(
                                          icon: Icon(Icons.remove),
                                          onPressed: () {
                                            setState(() {
                                              _questions.removeAt(index);
                                            });
                                          },
                                        ),
                                    ],
                                  );
                                }),
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
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
