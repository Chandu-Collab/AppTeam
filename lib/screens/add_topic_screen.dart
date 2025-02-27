import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:taurusai/models/topic.dart';
import 'package:taurusai/services/topic_service.dart';
import 'package:taurusai/widgets/input_widget.dart';

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
  bool _moreTopic = false; // Checkbox state to indicate if user wants to add another topic.
  List<Topic> _topics = [];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => _attachmentPath = result.files.single.path);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Add the current topic details to the list.
      // _topics.add(Topic(
      //   id: '',
      //   name: _nameController.text,
      //   description: _descriptionController.text,
      //   instructor: _instructorController.text,
      //   studyVideoUrl: _videoUrlController.text,
      //   attachment: _attachmentPath,
      //   title: _titleController.text,
      //   question: _questions,
      // ));

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
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: buildTextField(
                              'Name',
                              _nameController,
                              (value) => value == null || value.isEmpty
                                  ? 'Please enter a name'
                                  : null,
                              (value) => _nameController.text = value!,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: buildTextField(
                              'Title',
                              _titleController,
                              (value) => value == null || value.isEmpty
                                  ? 'Please enter a title'
                                  : null,
                              (value) => _titleController.text = value!,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: buildTextField(
                              'Instructor',
                              _instructorController,
                              (value) => value == null || value.isEmpty
                                  ? 'Please enter an instructor name'
                                  : null,
                              (value) => _instructorController.text = value!,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: buildTextField(
                              'Study Video URL',
                              _videoUrlController,
                              (value) => value == null || value.isEmpty
                                  ? 'Please enter a video URL'
                                  : null,
                              (value) => _videoUrlController.text = value!,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
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
                      SizedBox(height: 20),
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
                        Row(
                          children: [
                            Expanded(
                              child: buildTextField(
                                'Description',
                                _descriptionController,
                                (value) => value == null || value.isEmpty
                                    ? 'Please enter a description'
                                    : null,
                                (value) => _descriptionController.text = value!,
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 20),
                      Column(
                        children: List.generate(_questions.length, (index) {
                          return Column(
                            children: [
                              if (index > 0) SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: buildTextField(
                                      'Question ${index + 1}',
                                      TextEditingController(text: _questions[index]),
                                      (value) => value == null || value.isEmpty
                                          ? 'Please enter a question'
                                          : null,
                                      (value) => _questions[index] = value!,
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
                              ),
                            ],
                          );
                        }),
                      ),
                      SizedBox(height: 20),
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