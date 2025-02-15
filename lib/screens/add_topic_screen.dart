import 'package:flutter/material.dart';
import 'package:taurusai/models/topic.dart';
import 'package:taurusai/services/topic_service.dart';

class AddTopicScreen extends StatefulWidget {
  final String courseId;

  AddTopicScreen({required this.courseId});

  @override
  _AddTopicScreenState createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends State<AddTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  final TopicService _topicService = TopicService();

  String name = '';
  String description = '';
  String instructor = '';
  String? studyVideoUrl;
  String? attachment;
  String title = '';
  List<String> question = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Topic'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Topic Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a topic name' : null,
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
                onSaved: (value) => description = value!,
                maxLines: 3,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Instructor'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an instructor name' : null,
                onSaved: (value) => instructor = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Study Video URL'),
                onSaved: (value) => studyVideoUrl = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Attachment'),
                onSaved: (value) => attachment = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => title = value!,
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Questions (comma-separated)'),
                validator: (value) => value!.isEmpty
                    ? 'Please enter at least one question'
                    : null,
                onSaved: (value) => question = value!.split(','),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Add Topic'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Topic newTopic = Topic(
                      id: '', // This will be set by Firestore
                      name: name,
                      description: description,
                      instructor: instructor,
                      studyVideoUrl: studyVideoUrl,
                      attachment: attachment,
                      title: title,
                      question: question,
                    );
                    try {
                      String topicId =
                          await _topicService.createTopic(newTopic);
                      await _topicService.addTopicToCourse(
                          widget.courseId, topicId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Topic added successfully')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error adding topic: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
