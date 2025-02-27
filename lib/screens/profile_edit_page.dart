import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taurusai/models/address.dart';
import 'package:taurusai/models/skill.dart';
import 'package:taurusai/models/user.dart' as app_user;
import 'package:taurusai/screens/add_address_screen.dart';
import 'package:taurusai/screens/add_edit_skills.dart';
import 'package:taurusai/screens/address_list.dart';
import 'package:taurusai/services/add_address_service.dart';
import 'package:taurusai/services/skills_service.dart';
import 'package:taurusai/services/user_service.dart';
import 'package:taurusai/widgets/resume_upload_widget.dart';
import 'package:taurusai/widgets/input_widget.dart'; // Provides buildTextField
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/screens/education_filling_screen.dart';
import 'package:taurusai/models/education.dart'; // Education model
import 'package:taurusai/screens/education_edit_screen.dart';
import 'package:taurusai/screens/add_position_screen.dart';
import 'package:taurusai/screens/add_career_break_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class ProfileEditPage extends StatefulWidget {
  final app_user.User user;

  ProfileEditPage({required this.user});

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final AddressService _addressService = AddressService();
  final UserService _userService = UserService();
  final SkillService _skillsService = SkillService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;

  File? _image;
  final picker = ImagePicker();
  late Future<List<Address>> _addressesFuture;
  late Future<List<Skill>> _skillsFuture;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.profileName);
    _bioController = TextEditingController(text: widget.user.bio);
    _emailController = TextEditingController(text: widget.user.email);
    _addressesFuture = _fetchAddresses();
    _skillsFuture = _fetchSkills();
  }

  Future<List<Skill>> _fetchSkills() async {
    String? userId = getCurrentUserId();
    if (userId != null) {
      return await _skillsService.getSkillsForUser(userId);
    }
    return [];
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
      app_user.User updatedUser = widget.user.copyWith(
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

  // Stream for experiences stored under the current user's "experiences" subcollection.
  Stream<QuerySnapshot> getExperiencesStream() {
    String? userId = getCurrentUserId();
    if (userId != null) {
      return FirebaseFirestore.instance
          .collection('taurusai')
          .doc('users')
          .collection(userId)
          .doc('experiences')
          .collection('positions')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      return Stream.empty();
    }
  }

  // Shows a dialog with options to add either a Position or a Career Break.
  void _showAddExperienceOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Experience"),
          content: Text("Choose experience type"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dismiss the dialog.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPositionScreen(),
                  ),
                ).then((_) {
                  setState(() {}); // Refresh view after adding.
                });
              },
              child: Text("Add Position"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCareerBreakScreen(),
                  ),
                ).then((_) {
                  setState(() {});
                });
              },
              child: Text("Add Career Break"),
            ),
          ],
        );
      },
    );
  }

  // Get current user's UID using FirebaseAuth.
  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = getCurrentUserId();
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
          actions: [
            IconButton(
              icon: Icon(Icons.save, color: Colors.black),
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
                // Full Name
                Row(
                  children: [
                    Expanded(
                      child: buildTextField(
                        'Full Name',
                        _nameController,
                        (value) => value!.isEmpty ? 'Enter your name' : null,
                        (value) => _nameController.text = value!,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Email Address
                Row(
                  children: [
                    Expanded(
                      child: buildTextField(
                        'Email Address',
                        _emailController,
                        (value) => value!.isEmpty ? 'Enter your email' : null,
                        (value) => _emailController.text = value!,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Bio
                Row(
                  children: [
                    Expanded(
                      child: buildTextField(
                        'Bio',
                        _bioController,
                        null,
                        (value) => _bioController.text = value!,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Addresses Section
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
                                            userId: currentUserId ?? '')),
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
                SizedBox(height: 20),
                // Experiences Section
                Row(
                  children: [
                    Text('Experiences',
                        style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: _showAddExperienceOptions,
                    ),
                  ],
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: getExperiencesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Text("No experiences found.");
                    }
                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        String type = data['type'] ?? '';
                        Widget content;
                        if (type == 'position') {
                          // For a position, display title, company, employment type, and date range.
                          String start =
                              "${data['startMonth'] ?? ""} ${data['startYear'] ?? ""}";
                          String end = (data['currentlyWorking'] == true)
                              ? "Present"
                              : "${data['endMonth'] ?? ""} ${data['endYear'] ?? ""}";
                          content = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['title'] ?? "",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(data['company'] ?? ""),
                              Text(
                                  "Employment: ${data['employmentType'] ?? ""}"),
                              Text("Duration: $start - $end"),
                            ],
                          );
                        } else if (type == 'career_break') {
                          // For a career break, display career break type, location, date range, and description.
                          String start =
                              "${data['startMonth'] ?? ""} ${data['startYear'] ?? ""}";
                          String end = (data['currentlyOnBreak'] == true)
                              ? "Present"
                              : "${data['endMonth'] ?? ""} ${data['endYear'] ?? ""}";
                          content = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['careerBreakType'] ?? "Career Break",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text("Location: ${data['location'] ?? ""}"),
                              Text("Duration: $start - $end"),
                              if (data['description'] != null &&
                                  (data['description'] as String).isNotEmpty)
                                Text(data['description']),
                            ],
                          );
                        } else {
                          content = Text("Unknown experience type");
                        }
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: content,
                            trailing: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // When editing, pass the document data and ID to the appropriate screen.
                                if (type == 'position') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddPositionScreen(
                                        initialData: data,
                                        experienceId: doc.id,
                                      ),
                                    ),
                                  ).then((_) {
                                    setState(() {});
                                  });
                                } else if (type == 'career_break') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddCareerBreakScreen(
                                        initialData: data,
                                        experienceId: doc.id,
                                      ),
                                    ),
                                  ).then((_) {
                                    setState(() {});
                                  });
                                }
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                SizedBox(height: 20),
                // Education Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Education',
                            style: Theme.of(context).textTheme.titleLarge),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EducationFillingScreen()),
                            ).then((_) {
                              setState(() {
                                // Refresh the view after adding education.
                              });
                            });
                          },
                        ),
                      ],
                    ),
                    currentUserId == null
                        ? Container()
                        : StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('taurusai')
                                .doc('users')
                                .collection(currentUserId)
                                .doc('education')
                                .collection('details')
                                .orderBy('from', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Text('No education details found.');
                              }
                              return Column(
                                children: snapshot.data!.docs.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  Education edu = Education.fromJson(data);
                                  String dateRange =
                                      '${edu.from.toLocal().toString().split(' ')[0]} - ${edu.current ? 'Present' : edu.to != null ? edu.to!.toLocal().toString().split(' ')[0] : ''}';
                                  return Card(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 0),
                                    elevation: 2,
                                    child: ListTile(
                                      title: Text(edu.school),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              '${edu.degree} in ${edu.fieldOfStudy}'),
                                          Text(dateRange),
                                          if (edu.description != null &&
                                              edu.description!.isNotEmpty)
                                            Text(edu.description!),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EducationEditScreen(
                                                docId: doc.id,
                                                education: edu,
                                              ),
                                            ),
                                          ).then((_) {
                                            setState(() {
                                              // Refresh after editing if needed.
                                            });
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                  ],
                ),
                SizedBox(height: 20),
                // Skills Section (unchanged)
                FutureBuilder<List<Skill>>(
                  future: _skillsFuture,
                  builder: (context, snapshot) {
                    bool hasSkills =
                        snapshot.hasData && snapshot.data!.isNotEmpty;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Skills',
                                style: Theme.of(context).textTheme.titleLarge),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SkillFormScreen()),
                                ).then((_) {
                                  setState(() {
                                    _skillsFuture = _fetchSkills();
                                  });
                                });
                              },
                            ),
                            if (hasSkills)
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddressListPage(
                                          userId: currentUserId ?? ''),
                                    ),
                                  ).then((_) {
                                    setState(() {
                                      _skillsFuture = _fetchSkills();
                                    });
                                  });
                                },
                              ),
                          ],
                        ),
                        if (snapshot.connectionState == ConnectionState.waiting)
                          Center(child: CircularProgressIndicator())
                        else if (!hasSkills)
                          Text("No skills found.")
                        else
                          Column(
                            children: snapshot.data!
                                .map((skill) => ListTile(
                                      title: Text(skill.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      subtitle:
                                          Text("Level: ${skill.proficiency}"),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SkillFormScreen(
                                                          skillId: skill.id),
                                                ),
                                              ).then((_) {
                                                setState(() {
                                                  _skillsFuture =
                                                      _fetchSkills();
                                                });
                                              });
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () async {
                                              bool confirmDelete =
                                                  await showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: Text('Delete Skill'),
                                                  content: Text(
                                                      'Are you sure you want to delete this skill?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, false),
                                                      child: Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, true),
                                                      child: Text('Delete'),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirmDelete) {
                                                await SkillService()
                                                    .deleteSkill(currentUserId!,
                                                        skill.id!);
                                                setState(() {
                                                  _skillsFuture =
                                                      _fetchSkills();
                                                });

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Skill deleted successfully!')),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                      ],
                    );
                  },
                ),

                SizedBox(height: 20),
                // Resume Section (unchanged)
                Text('Resume', style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 8),
                ResumeUploadWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
