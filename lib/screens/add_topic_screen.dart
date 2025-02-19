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

class _AddTopicScreenState extends State<AddTopicScreen> {
  final TopicService _topicService = TopicService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructorController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final List<String> _questions = [""];

  bool _isDescriptionExpanded = false;
  String? _attachmentPath;
  bool _moreTopic =
      false; // Checkbox state to indicate if user wants to add another topic.
  List<Topic> _topics = [];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => _attachmentPath = result.files.single.path);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Add the current topic details to the list.
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

      if (_moreTopic) {
        // If the checkbox is ticked, clear the form for the next topic.
        _clearForm();
        // Reset the checkbox for the next entry.
        setState(() {
          _moreTopic = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Topic saved. Please add another topic.')),
        );
      } else {
        // Otherwise, save all topics to the server.
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
    setState(() => _attachmentPath = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Topic'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Name'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a name'
                            : null,
                      ),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(labelText: 'Title'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a title'
                            : null,
                      ),
                      TextFormField(
                        controller: _instructorController,
                        decoration: InputDecoration(labelText: 'Instructor'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter an instructor name'
                            : null,
                      ),
                      TextFormField(
                        controller: _videoUrlController,
                        decoration:
                            InputDecoration(labelText: 'Study Video URL'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a video URL'
                            : null,
                      ),
                      SizedBox(height: 10),
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
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            border: OutlineInputBorder(),
                            hintText: 'Enter description',
                          ),
                        ),
                      SizedBox(height: 10),
                      Column(
                        children: List.generate(_questions.length, (index) {
                          return Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Question',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    _questions[index] = value;
                                  },
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
                      SizedBox(height: 10),
                      CheckboxListTile(
                        title: Text('More Topic?'),
                        value: _moreTopic,
                        onChanged: (bool? value) {
                          setState(() {
                            _moreTopic = value ?? false;
                          });
                        },
                      ),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text('Save Topic'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
