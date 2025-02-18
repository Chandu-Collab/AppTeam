import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/screens/home_page.dart';
import 'package:taurusai/services/user_service.dart';
import 'package:country_code_picker/country_code_picker.dart';

class UserDetailsForm extends StatefulWidget {
  final User user;

  UserDetailsForm({required this.user});

  @override
  _UserDetailsFormState createState() => _UserDetailsFormState();
}

class _UserDetailsFormState extends State<UserDetailsForm> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String bio;
  late String username;
  late String mobile;
  late String email;
  String countryCode = '+91'; // Default country code
  File? _image;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    name = widget.user.profileName ?? '';
    bio = widget.user.bio ?? '';
    mobile = widget.user.mobile ?? '';
    username = widget.user.userName ?? '';
    email = widget.user.email ?? '';
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
      appBar: AppBar(title: Text('Complete Your Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
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
              SizedBox(height: 20),
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                initialValue: username,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter your username';
                  } else if (RegExp(r'[!@#$%^&*()+\-=\[\]{};:"\\|,.<>\/? ]').hasMatch(value)) {
                    return 'Username cannot contain special characters or spaces';
                  } else if (value.length < 4) {
                    return 'Username must be at least 4 characters';
                  } else if (value.length > 15) {
                    return 'Username must be at most 15 characters';
                  } else if (RegExp(' ').hasMatch(value)) {
                    return 'Username cannot contain spaces';
                  }
                  return null;
                },
                onSaved: (value) => username = value!,
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: email,
                decoration: InputDecoration(labelText: 'Email'),
                enabled: true,
              ),
              SizedBox(height: 20),
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
                      initialValue: mobile,
                      decoration: InputDecoration(labelText: 'Mobile'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter your Mobile no';
                        } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Mobile number can only contain digits';
                        }
                        return null;
                      },
                      onSaved: (value) => mobile = value!,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: bio,
                decoration: InputDecoration(labelText: 'Bio'),
                maxLines: 3,
                onSaved: (value) => bio = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Save and Continue'),
                onPressed: () async {
                  print('Save and Continue button pressed');
                  if (_formKey.currentState!.validate()) {
                    print('Form is valid');
                    _formKey.currentState!.save();
                    print('Form saved');
                    String? imageUrl;
                    if (_image != null) {
                      imageUrl = await _userService.uploadProfileImage(
                          widget.user.id, _image!);
                      print('Image uploaded: $imageUrl');
                    }
                    User updatedUser = widget.user.copyWith(
                      profileName: name,
                      bio: bio,
                      userName: username,
                      url: imageUrl ?? widget.user.url,
                      mobile: '$countryCode$mobile',
                      email: email,
                      isProfileComplete: true,
                    );
                    await _userService.updateUser(updatedUser);
                    print('User updated');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(
                              user: updatedUser)), // Updated Navigation
                    );
                    print('Navigation to HomePage');
                  } else {
                    print('Form is not valid');
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
