import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/experience.dart';

class ExperienceService {
  final CollectionReference _experiencesCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('users')
      .collection('experiences');

  Future<String> createExperience(Experience experience) async {
    DocumentReference docRef =
        await _experiencesCollection.add(experience.toJson());
    return docRef.id;
  }

  Future<Experience?> getExperience(String experienceId) async {
    DocumentSnapshot doc = await _experiencesCollection.doc(experienceId).get();
    return doc.exists
        ? Experience.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  Future<List<Experience>> getExperiencesByUserId(String userId) async {
    QuerySnapshot snapshot =
        await _experiencesCollection.where('userId', isEqualTo: userId).get();
    return snapshot.docs
        .map((doc) => Experience.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Experience>> getAllExperiences() async {
    QuerySnapshot snapshot = await _experiencesCollection.get();
    return snapshot.docs
        .map((doc) => Experience.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateExperience(Experience experience) async {
    await _experiencesCollection.doc(experience.id).update(experience.toJson());
  }

  Future<void> deleteExperience(String experienceId) async {
    await _experiencesCollection.doc(experienceId).delete();
  }
}
