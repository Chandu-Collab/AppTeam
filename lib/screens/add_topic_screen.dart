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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _instructorController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  final List<String> _questions = [""];

  bool _isDescriptionExpanded = false;
  String? _attachmentPath;

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
        id: '', // This will be set by Firestore
        name: _nameController.text,
        description: _descriptionController.text,
        instructor: _instructorController.text,
        studyVideoUrl: _videoUrlController.text,
        attachment: _attachmentPath,
        title: _titleController.text,
        question: _questions,
      );
      try {
        String topicId = await _topicService.createTopic(newTopic);
        await _topicService.addTopicToCourse(widget.courseId, topicId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Topic added successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding topic: $e')),
        );
      }
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Add Topic",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                            labelText: 'Name', border: OutlineInputBorder()),
                        validator: (value) =>
                            (value == null || value.length < 2)
                                ? 'Name must be at least 2 characters'
                                : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                            labelText: 'Title', border: OutlineInputBorder()),
                        validator: (value) =>
                            (value == null || value.length < 3)
                                ? 'Title must be at least 3 characters'
                                : null,
                      ),
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => setState(() =>
                            _isDescriptionExpanded = !_isDescriptionExpanded),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Description'),
                            Icon(_isDescriptionExpanded
                                ? Icons.remove
                                : Icons.add),
                          ],
                        ),
                      ),
                      if (_isDescriptionExpanded)
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: InputDecoration(
                              hintText: 'Enter topic description',
                              border: OutlineInputBorder()),
                        ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _instructorController,
                        decoration: InputDecoration(
                            labelText: 'Instructor',
                            border: OutlineInputBorder()),
                        validator: (value) =>
                            (value == null || value.length < 2)
                                ? 'Instructor name is required'
                                : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _videoUrlController,
                        decoration: InputDecoration(
                            labelText: 'Study Video URL',
                            prefixIcon: Icon(Icons.link),
                            border: OutlineInputBorder()),
                        validator: (value) => (value!.isNotEmpty &&
                                Uri.tryParse(value)?.hasAbsolutePath != true)
                            ? 'Please enter a valid URL'
                            : null,
                      ),
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: _pickFile,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.attach_file),
                            SizedBox(width: 8),
                            Text(_attachmentPath ?? 'Attach a file'),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Questions'),
                          ..._questions.asMap().entries.map((entry) {
                            int index = entry.key;
                            return Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: entry.value,
                                    decoration: InputDecoration(
                                        hintText: 'Question ${index + 1}',
                                        border: OutlineInputBorder()),
                                    onChanged: (value) =>
                                        _questions[index] = value,
                                  ),
                                ),
                                if (index > 0)
                                  IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () => setState(
                                          () => _questions.removeAt(index))),
                              ],
                            );
                          }).toList(),
                          IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () =>
                                  setState(() => _questions.add(""))),
                        ],
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: Icon(Icons.save),
                        label: Text('Save Topic'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white),
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
