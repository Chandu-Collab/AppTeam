import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/admission.dart';

class EnrollmentService {
  final CollectionReference _admissionsCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('courses')
      .collection('admissions');

  Future<String> createEnrollment(Admission admission) async {
    DocumentReference docRef =
        await _admissionsCollection.add(admission.toJson());
    return docRef.id;
  }

  Future<List<Admission>> getUserEnrollments(String userId) async {
    QuerySnapshot snapshot =
        await _admissionsCollection.where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Admission.fromJson(data);
    }).toList();
  }

  Future<Admission?> getEnrollment(String admissionId) async {
    DocumentSnapshot doc = await _admissionsCollection.doc(admissionId).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Admission.fromJson(data);
    }
    return null;
  }

  Future<void> updateEnrollment(Admission admission) async {
    await _admissionsCollection.doc(admission.id).update(admission.toJson());
  }
}
