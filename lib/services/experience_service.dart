import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/experience.dart';

class ExperienceService {
  /// Returns the reference to the experiences collection for a specific user
  CollectionReference _experiencesCollection(String userId) =>
      FirebaseFirestore.instance
          .collection('taurusai')
          .doc(userId)
          .collection('experiences');

  /// Create a new experience for a specific user
  Future<String> createExperience(String userId, Experience experience) async {
    DocumentReference docRef =
        _experiencesCollection(userId).doc(); // Generate a new document reference
    experience.id = docRef.id; // Assign the generated ID to the experience
    await docRef.set(experience
        .toJson()); // Use set() instead of add() to ensure the ID is stored
    print('Experience created with ID: ${docRef.id}');
    return docRef.id;
  }

  /// Retrieve a single experience by ID for a specific user
  Future<Experience?> getExperience(String userId, String experienceId) async {
    DocumentSnapshot doc =
        await _experiencesCollection(userId).doc(experienceId).get();
    return doc.exists
        ? Experience.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  /// Retrieve all experiences for a specific user
  Future<List<Experience>> getExperiencesForUser(String userId) async {
    QuerySnapshot snapshot = await _experiencesCollection(userId).get();
    print("Total experiences: ${snapshot.docs.length}");
    return snapshot.docs
        .map((doc) => Experience.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Update an existing experience for a specific user
  Future<void> updateExperience(String userId, Experience experience) async {
    await _experiencesCollection(userId).doc(experience.id).update(experience.toJson());
  }

  /// Delete an experience by ID for a specific user
  Future<void> deleteExperience(String userId, String experienceId) async {
    await _experiencesCollection(userId).doc(experienceId).delete();
  }

  // Delete all experiences for a specific user
  Future<void> deleteAllExperiences(String userId) async {
    QuerySnapshot snapshot = await _experiencesCollection(userId).get();

    for (DocumentSnapshot doc in snapshot.docs) {
      await doc.reference.delete();
    }

    print("All experiences deleted for user: $userId");
  }
}