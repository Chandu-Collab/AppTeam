import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:taurusai/models/profile.dart';

class ProfileService {
  final CollectionReference _profilesCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('users')
      .collection('profiles');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> createProfile(Profile profile) async {
    await _profilesCollection.doc(profile.userId).set(profile.toJson());
  }

  Future<Profile?> getProfile(String userId) async {
    DocumentSnapshot doc = await _profilesCollection.doc(userId).get();
    return doc.exists
        ? Profile.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  Future<void> updateProfile(Profile profile) async {
    await _profilesCollection.doc(profile.userId).update(profile.toJson());
  }

  Future<void> deleteProfile(String userId) async {
    await _profilesCollection.doc(userId).delete();
  }

  Future<String> uploadResume(String userId, File resumeFile) async {
    String fileName =
        'resumes/$userId/${DateTime.now().millisecondsSinceEpoch}.pdf';
    Reference storageRef = _storage.ref().child(fileName);
    UploadTask uploadTask = storageRef.putFile(resumeFile);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    await _profilesCollection.doc(userId).update({
      'resumeUrl': downloadUrl,
    });

    return downloadUrl;
  }
}
