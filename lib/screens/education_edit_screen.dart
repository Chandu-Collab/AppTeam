import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taurusai/models/education.dart'; // Your provided model

class EducationEditScreen extends StatefulWidget {
  final String docId;
  final Education education;

  EducationEditScreen({required this.docId, required this.education});

  @override
  _EducationEditScreenState createState() => _EducationEditScreenState();
}

class _EducationEditScreenState extends State<EducationEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _schoolController;
  late TextEditingController _degreeController;
  late TextEditingController _fieldController;
  late TextEditingController _descriptionController;

  DateTime? _fromDate;
  DateTime? _toDate;
  bool _current = false;

  @override
  void initState() {
    super.initState();
    _schoolController = TextEditingController(text: widget.education.school);
    _degreeController = TextEditingController(text: widget.education.degree);
    _fieldController =
        TextEditingController(text: widget.education.fieldOfStudy);
    _descriptionController =
        TextEditingController(text: widget.education.description);
    _fromDate = widget.education.from;
    _toDate = widget.education.to;
    _current = widget.education.current;
  }

  Future<void> _selectFromDate() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? now,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked;
      });
    }
  }

  Future<void> _selectToDate() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? now,
      firstDate: _fromDate ?? DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _toDate = picked;
      });
    }
  }

  Future<void> _updateEducation() async {
    if (_formKey.currentState!.validate() &&
        _fromDate != null &&
        (_current || _toDate != null)) {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        Education updatedEdu = Education(
          school: _schoolController.text,
          degree: _degreeController.text,
          fieldOfStudy: _fieldController.text,
          from: _fromDate!,
          to: _current ? null : _toDate,
          current: _current,
          description: _descriptionController.text,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('education')
            .doc(widget.docId)
            .update(updatedEdu.toJson());
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Education'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _schoolController,
                decoration: InputDecoration(labelText: 'School/University'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter your school/university'
                    : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _degreeController,
                decoration: InputDecoration(labelText: 'Degree'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter your degree'
                    : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _fieldController,
                decoration: InputDecoration(labelText: 'Field of Study'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter your field of study'
                    : null,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(labelText: 'From Date'),
                      onTap: _selectFromDate,
                      controller: TextEditingController(
                        text: _fromDate != null
                            ? _fromDate!.toLocal().toString().split(' ')[0]
                            : '',
                      ),
                      validator: (value) =>
                          _fromDate == null ? 'Select start date' : null,
                    ),
                  ),
                  SizedBox(width: 10),
                  if (!_current)
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(labelText: 'To Date'),
                        onTap: _selectToDate,
                        controller: TextEditingController(
                          text: _toDate != null
                              ? _toDate!.toLocal().toString().split(' ')[0]
                              : '',
                        ),
                        validator: (value) => !_current && _toDate == null
                            ? 'Select end date'
                            : null,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Currently Studying'),
                  Switch(
                    value: _current,
                    onChanged: (val) {
                      setState(() {
                        _current = val;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    InputDecoration(labelText: 'Description (Optional)'),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateEducation,
                child: Text('Update Education'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
