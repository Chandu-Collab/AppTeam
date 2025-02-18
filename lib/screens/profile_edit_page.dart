import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/services/user_service.dart';
import 'package:taurusai/widgets/resume_upload_widget.dart';
import 'package:country_code_picker/country_code_picker.dart';

class ProfileEditPage extends StatefulWidget {
  final User user;

  ProfileEditPage({required this.user});

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  File? _image;
  final picker = ImagePicker();
  String countryCode = '+91'; // Default country code

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.profileName);
    _bioController = TextEditingController(text: widget.user.bio);
    _emailController = TextEditingController(text: widget.user.email);
    _mobileController = TextEditingController(text: widget.user.mobile);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: getImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : (widget.user.url != null
                                ? NetworkImage(widget.user.url!)
                                : AssetImage('assets/default_profile.png'))
                            as ImageProvider,
                    child: _image == null && widget.user.url == null
                        ? Icon(Icons.camera_alt, size: 50)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your email' : null,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  CountryCodePicker(
                    onChanged: (country) {
                      setState(() {
                        countryCode = country.dialCode!;
                      });
                    },
                    initialSelection: 'IN',
                    favorite: ['+91', 'IN'],
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _mobileController,
                      decoration: InputDecoration(labelText: 'Mobile'),
                      validator: (value) => value!.isEmpty ? 'Enter your Mobile no' : null,
                      enabled: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Text('Resume', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 8),
              ResumeUploadWidget(),
              SizedBox(height: 16),
              // Add more fields for education, experience, and skills here
              // For example:
              Text('Education', style: Theme.of(context).textTheme.titleLarge),
              // Add education fields
              Text('Experience', style: Theme.of(context).textTheme.titleLarge),
              // Add experience fields
              Text('Skills', style: Theme.of(context).textTheme.titleLarge),
              // Add skills fields
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() async {
  if (_formKey.currentState!.validate()) {
    String? imageUrl;
    if (_image != null) {
      imageUrl = await _userService.uploadProfileImage(widget.user.id, _image!);
    }

    // Check if the mobile number already contains the country code
    String mobileNumber = _mobileController.text;
    // if (!mobileNumber.startsWith(countryCode)) {
    //   mobileNumber = '$countryCode$mobileNumber';
    // }

    User updatedUser = widget.user.copyWith(
      profileName: _nameController.text,
      email: _emailController.text,
      bio: _bioController.text,
      url: imageUrl ?? widget.user.url,
      mobile: mobileNumber,
    );

    await _userService.updateUser(updatedUser);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully')),
    );
    Navigator.pop(context);
  }
}
}
