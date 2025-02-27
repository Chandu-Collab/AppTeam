import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/skill.dart';

class SkillService {
  /// Returns the reference to the skills collection for a specific user
  CollectionReference _skillsCollection(String userId) =>
      FirebaseFirestore.instance
          .collection('taurusai')
          .doc(userId)
          .collection('skills');

  /// Create a new skill for a specific user
  Future<String> createSkill(String userId, Skill skill) async {
    DocumentReference docRef =
        _skillsCollection(userId).doc(); // Generate a new document reference
    skill.id = docRef.id; // Assign the generated ID to the skill
    await docRef.set(skill
        .toJson()); // Use set() instead of add() to ensure the ID is stored
    print('Skill created with ID: ${docRef.id}');
    return docRef.id;
  }

  /// Retrieve a single skill by ID for a specific user
  Future<Skill?> getSkill(String userId, String skillId) async {
    DocumentSnapshot doc = await _skillsCollection(userId).doc(skillId).get();
    return doc.exists
        ? Skill.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  /// Retrieve all skills for a specific user
  Future<List<Skill>> getSkillsForUser(String userId) async {
    QuerySnapshot snapshot = await _skillsCollection(userId).get();
    print("Total skills: ${snapshot.docs.length}");
    return snapshot.docs
        .map((doc) => Skill.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Update an existing skill for a specific user
  Future<void> updateSkill(String userId, Skill skill) async {
    await _skillsCollection(userId).doc(skill.id).update(skill.toJson());
  }

  /// Delete a skill by ID for a specific user
  Future<void> deleteSkill(String userId, String skillId) async {
    await _skillsCollection(userId).doc(skillId).delete();
  }

  // Delete all skills for a specific user
  Future<void> deleteAllSkills(String userId) async {
    QuerySnapshot snapshot = await _skillsCollection(userId).get();

    for (DocumentSnapshot doc in snapshot.docs) {
      await doc.reference.delete();
    }

    print("All skills deleted for user: $userId");
  }
}
