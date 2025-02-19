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
                Text('Resume', style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 8),
                ResumeUploadWidget(),
                SizedBox(height: 16),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
