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
import 'package:taurusai/widgets/input_widget.dart'; // Import the buildTextField function
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/screens/education_filling_screen.dart';
import 'package:taurusai/models/education.dart'; // Import the Education class
import 'package:taurusai/screens/education_edit_screen.dart';

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
                        Row(
                          children: [
                            Text('Experiences',
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
                        // ... inside the build() method of ProfileEditPage, where you want the Education section to appear:
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Education',
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
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
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(getCurrentUserId())
                                  .collection('education')
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
                      ],
                    );
                  },
                ),
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
