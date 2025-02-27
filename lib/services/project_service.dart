import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/project.dart';

class ProjectService {
  final CollectionReference _projectsCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('users')
      .collection('projects');

  Future<String> createProject(Project project) async {
    DocumentReference docRef = await _projectsCollection.add(project.toJson());
    return docRef.id;
  }

  Future<Project?> getProject(String projectId) async {
    DocumentSnapshot doc = await _projectsCollection.doc(projectId).get();
    return doc.exists
        ? Project.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  Future<List<Project>> getProjectsByUserId(String userId) async {
    QuerySnapshot snapshot =
        await _projectsCollection.where('userId', isEqualTo: userId).get();
    return snapshot.docs
        .map((doc) => Project.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Project>> getAllProjects() async {
    QuerySnapshot snapshot = await _projectsCollection.get();
    return snapshot.docs
        .map((doc) => Project.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Future<void> updateProject(Project project) async {
  //   await _projectsCollection.doc(project.id).update(project.toJson());
  // }

  Future<void> deleteProject(String projectId) async {
    await _projectsCollection.doc(projectId).delete();
  }
}
