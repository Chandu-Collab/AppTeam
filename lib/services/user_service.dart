import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:taurusai/models/profile.dart';
import 'package:taurusai/models/user.dart';

class UserService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('users')
      .collection('accounts');
  final CollectionReference _profilesCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('users')
      .collection('profiles');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> createUser(User user) async {
    await _usersCollection.doc(user.id).set(user.toJson());
  }

  Future<User?> getUser(String userId) async {
    DocumentSnapshot doc = await _usersCollection.doc(userId).get();
    return doc.exists
        ? User.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  Future<void> updateUser(User user) async {
    await _usersCollection.doc(user.id).update(user.toJson());
  }

  Future<void> deleteUser(String userId) async {
    await _usersCollection.doc(userId).delete();
    await _profilesCollection.doc(userId).delete();
  }

  Future<Profile?> getProfile(String userId) async {
    DocumentSnapshot doc = await _profilesCollection.doc(userId).get();
    return doc.exists
        ? Profile.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  Future<void> createOrUpdateProfile(Profile profile) async {
    await _profilesCollection
        .doc(profile.userId)
        .set(profile.toJson(), SetOptions(merge: true));
  }

  Future<bool> isProfileComplete(String userId) async {
    DocumentSnapshot doc = await _usersCollection.doc(userId).get();
    return doc.exists &&
        (doc.data() as Map<String, dynamic>)['isProfileComplete'] == true;
  }

  Future<bool> hasResume(String userId) async {
    DocumentSnapshot doc = await _usersCollection.doc(userId).get();
    return doc.exists &&
        (doc.data() as Map<String, dynamic>)['hasResume'] == true;
  }

  Future<String> uploadResume(String userId, File resumeFile) async {
    String fileName =
        'resumes/$userId/${DateTime.now().millisecondsSinceEpoch}.pdf';
    Reference storageRef = _storage.ref().child(fileName);
    UploadTask uploadTask = storageRef.putFile(resumeFile);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    await _usersCollection.doc(userId).update({
      'hasResume': true,
      'resumeUrl': downloadUrl,
    });

    return downloadUrl;
  }

  Future<User?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = userId; // Ensure the id is set
        return User.fromJson(data);
      }
    } catch (e) {
      User? user;
      if (userId != null) {
        user = User(
          id: userId,
          userName: '',
          email: '',
          profileName: '',
          mobile: '',
          url: '',
          isProfileComplete: false,
          hasResume: false,
        );
        await createUser(user);
      }
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    QuerySnapshot snapshot = await _usersCollection.get();
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return User.fromJson(data);
    }).toList();
  }

  Future<String> uploadProfileImage(String userId, File imageFile) async {
    String fileName =
        'profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference storageRef = _storage.ref().child(fileName);
    UploadTask uploadTask = storageRef.putFile(imageFile);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    await _usersCollection.doc(userId).update({
      'url': downloadUrl,
    });

    return downloadUrl;
  }

  Future<User?> getLatestUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = userId;
        return User.fromJson(data);
      }
    } catch (e) {
      print('Error fetching latest user data: $e');
    }
    return null;
  }
}
