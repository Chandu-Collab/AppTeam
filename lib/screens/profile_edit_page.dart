import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taurusai/models/address.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/screens/add_address_screen.dart';
import 'package:taurusai/screens/address_list.dart';
import 'package:taurusai/services/add_address_service.dart';
import 'package:taurusai/services/user_service.dart';
import 'package:taurusai/widgets/resume_upload_widget.dart';

class ProfileEditPage extends StatefulWidget {
  final User user;

  ProfileEditPage({required this.user});

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final AddressService _addressService = AddressService();
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;

  File? _image;
  final picker = ImagePicker();
  late Future<List<Address>> _addressesFuture;

  // Dummy data for Experiences, Education, and Skills.
  List<Map<String, String>> _experiences = [
    {
      'title': 'Software Engineer',
      'company': 'Google Inc.',
      'duration': 'Jan 2018 - Present',
    },
    {
      'title': 'Mobile Developer',
      'company': 'Facebook',
      'duration': 'Feb 2016 - Dec 2017',
    },
  ];

  List<Map<String, String>> _education = [
    {
      'degree': 'B.Sc. Computer Science',
      'institution': 'Stanford University',
      'year': '2012 - 2016',
    },
  ];

  List<String> _skills = [
    'Flutter',
    'Dart',
    'JavaScript',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.profileName);
    _bioController = TextEditingController(text: widget.user.bio);
    _emailController = TextEditingController(text: widget.user.email);
    _addressesFuture = _fetchAddresses();
  }

  Future<List<Address>> _fetchAddresses() async {
    String? userId = getCurrentUserId();
    if (userId != null) {
      return await _addressService.getAddressesForUser(userId);
    }
    return [];
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl;
      if (_image != null) {
        imageUrl =
            await _userService.uploadProfileImage(widget.user.id, _image!);
      }
      User updatedUser = widget.user.copyWith(
        profileName: _nameController.text,
        email: _emailController.text,
        bio: _bioController.text,
        url: imageUrl ?? widget.user.url,
      );
      await _userService.updateUser(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    }
  }

  // Example functions for adding new experiences, education, or skills.
  // You can replace these with your own navigation or dialog logic.
  void _addExperience() {
    // For example, open a dialog to collect experience details.
  }

  void _addEducation() {
    // For example, open a dialog to collect education details.
  }

  void _addSkill() {
    // For example, open a dialog to collect a new skill.
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Edit Profile',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : (widget.user.url != null
                                  ? NetworkImage(widget.user.url!)
                                  : AssetImage('assets/default_profile.png'))
                              as ImageProvider,
                      child: _image == null && widget.user.url == null
                          ? Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your name' : null,
                ),
                SizedBox(height: 16),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your email' : null,
                ),
                SizedBox(height: 16),
                // Bio Field
                TextFormField(
                  controller: _bioController,
                  decoration: InputDecoration(
                    labelText: 'Short Bio',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 24),
                // Addresses Section (using FutureBuilder)
                FutureBuilder<List<Address>>(
                  future: _addressesFuture,
                  builder: (context, snapshot) {
                    bool hasAddresses =
                        snapshot.hasData && snapshot.data!.isNotEmpty;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Addresses',
                                style: Theme.of(context).textTheme.titleLarge),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AddressFormScreen()),
                                ).then((_) {
                                  setState(() {
                                    _addressesFuture = _fetchAddresses();
                                  });
                                });
                              },
                            ),
                            if (hasAddresses)
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddressListPage(
                                            userId:
                                                getCurrentUserId() as String)),
                                  ).then((_) {
                                    setState(() {
                                      _addressesFuture = _fetchAddresses();
                                    });
                                  });
                                },
                              ),
                          ],
                        ),
                        if (snapshot.connectionState == ConnectionState.waiting)
                          Center(child: CircularProgressIndicator())
                        else if (!hasAddresses)
                          Text("No addresses found.")
                        else
                          Column(
                            children: snapshot.data!
                                .map((address) => ListTile(
                                      title: Text(
                                          "${address.street}, ${address.city}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text(
                                          "${address.state}, ${address.country} - ${address.postalCode}"),
                                      trailing: IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AddressFormScreen(
                                                        addressId: address.id)),
                                          ).then((_) {
                                            setState(() {
                                              _addressesFuture =
                                                  _fetchAddresses();
                                            });
                                          });
                                        },
                                      ),
                                    ))
                                .toList(),
                          ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 24),
                // Experiences Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Experiences',
                        style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: _addExperience,
                    ),
                  ],
                ),
                _experiences.isEmpty
                    ? Text("No experiences added.")
                    : Column(
                        children: _experiences.map((exp) {
                          return BuildCard(
                            title: exp['title']!,
                            subtitle: exp['company']!,
                            description: exp['duration']!,
                            trailing: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Handle edit experience
                              },
                            ),
                          );
                        }).toList(),
                      ),
                SizedBox(height: 24),
                // Education Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Education',
                        style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: _addEducation,
                    ),
                  ],
                ),
                _education.isEmpty
                    ? Text("No education added.")
                    : Column(
                        children: _education.map((edu) {
                          return BuildCard(
                            title: edu['degree']!,
                            subtitle: edu['institution']!,
                            description: edu['year']!,
                            trailing: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Handle edit education
                              },
                            ),
                          );
                        }).toList(),
                      ),
                SizedBox(height: 24),
                // Skills Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Skills',
                        style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: _addSkill,
                    ),
                  ],
                ),
                _skills.isEmpty
                    ? Text("No skills added.")
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _skills
                            .map((skill) => Chip(
                                  label: Text(skill),
                                  backgroundColor: Colors.grey[200],
                                ))
                            .toList(),
                      ),
                SizedBox(height: 24),
                // Resume Upload Section
                Text('Resume', style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 8),
                ResumeUploadWidget(),
                SizedBox(height: 24),
                // Save Button
                Center(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: Text('Save Profile'),
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

/// A reusable card widget to display experience, education, or similar profile items.
/// This is designed to mimic a LinkedIn-style experience card.
class BuildCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? description;
  final Widget? trailing;

  const BuildCard({
    Key? key,
    required this.title,
    required this.subtitle,
    this.description,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and trailing action (e.g., edit)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            SizedBox(height: 4),
            // Subtitle (e.g., company or institution)
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            // Optional description (e.g., duration or additional info)
            if (description != null) ...[
              SizedBox(height: 8),
              Text(
                description!,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
