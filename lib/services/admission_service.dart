import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/admission.dart';

class AdmissionService {
  final CollectionReference _admissionsCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('courses')
      .collection('admissions');

  Future<String> createAdmission(Admission admission) async {
    DocumentReference docRef =
        await _admissionsCollection.add(admission.toJson());
    return docRef.id;
  }

  Future<Admission?> getAdmission(String admissionId) async {
    DocumentSnapshot doc = await _admissionsCollection.doc(admissionId).get();
    return doc.exists
        ? Admission.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  Future<List<Admission>> getAdmissionsForUser(String userId) async {
    QuerySnapshot snapshot =
        await _admissionsCollection.where('userId', isEqualTo: userId).get();
    return snapshot.docs
        .map((doc) => Admission.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateAdmission(Admission admission) async {
    await _admissionsCollection.doc(admission.id).update(admission.toJson());
  }

  Future<void> deleteAdmission(String admissionId) async {
    await _admissionsCollection.doc(admissionId).delete();
  }
}
