import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:taurusai/models/skill.dart';
import 'package:taurusai/services/skills_service.dart';
import 'package:taurusai/widgets/input_widget.dart';
import 'package:taurusai/widgets/button_widget.dart';

// Function to get the current user ID
String? getCurrentUserId() {
  final auth.User? user = auth.FirebaseAuth.instance.currentUser;
  return user?.uid;
}

class SkillFormScreen extends StatefulWidget {
  final String? skillId;

  SkillFormScreen({this.skillId});

  @override
  _SkillFormScreenState createState() => _SkillFormScreenState();
}

class _SkillFormScreenState extends State<SkillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String proficiency = '';
  String description = '';
  final SkillService _skillService = SkillService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedProficiency;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.skillId != null) {
      _loadSkillData();
    }
  }

  Future<void> _loadSkillData() async {
    String? userId = getCurrentUserId();
    if (userId != null && widget.skillId != null) {
      Skill? skill = await _skillService.getSkill(userId, widget.skillId!);
      if (skill != null) {
        setState(() {
          _nameController.text = skill.name;
          _selectedProficiency = skill.proficiency;
          _descriptionController.text = skill.description ?? '';
          _isEditing = true;
        });
      }
    }
  }

  void _saveSkill() async {
    if (_formKey.currentState!.validate()) {
      String? userId = getCurrentUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in")),
        );
        return;
      }

      Skill newSkill = Skill(
        id: widget.skillId ?? '',
        name: _nameController.text,
        proficiency: _selectedProficiency!,
        description: _descriptionController.text,
      );

      try {
        if (_isEditing) {
          await _skillService.updateSkill(userId, newSkill);
        } else {
          await _skillService.createSkill(userId, newSkill);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Skill saved successfully!")),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save skill: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Add Skill",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("Fill in your skill details",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildTextField(
                        "Skill Name",
                        _nameController,
                        (value) =>
                            value!.isEmpty ? "Skill name is required" : null,
                        (value) => name = value!,
                        icon: Icons.code,
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: 300,
                        child: DropdownButtonFormField<String>(
                          value: _selectedProficiency,
                          decoration:
                              _inputDecoration("Proficiency Level", Icons.star),
                          items:
                              ["Beginner", "Intermediate", "Advanced", "Expert"]
                                  .map((level) => DropdownMenuItem(
                                        value: level,
                                        child: Text(level),
                                      ))
                                  .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedProficiency = value),
                          validator: (value) =>
                              value == null ? "Select a proficiency" : null,
                        ),
                      ),
                      SizedBox(height: 16),
                      buildTextField(
                        "Description (Optional)",
                        _descriptionController,
                        (value) => null,
                        (value) => description = value!,
                        icon: Icons.info_outline,
                      ),
                      SizedBox(height: 20),
                      buildButton(_saveSkill, text: "Save Skill"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIcon: Icon(icon),
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }
}
