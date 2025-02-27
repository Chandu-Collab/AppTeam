import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/certificate.dart';

class CertificateService {
  final CollectionReference _certificatesCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('users')
      .collection('certificates');

  Future<String> createCertificate(Certificate certificate) async {
    DocumentReference docRef =
        await _certificatesCollection.add(certificate.toJson());
    return docRef.id;
  }

  Future<Certificate?> getCertificate(String certificateId) async {
    DocumentSnapshot doc =
        await _certificatesCollection.doc(certificateId).get();
    return doc.exists
        ? Certificate.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  Future<List<Certificate>> getCertificatesByUserId(String userId) async {
    QuerySnapshot snapshot =
        await _certificatesCollection.where('userId', isEqualTo: userId).get();
    return snapshot.docs
        .map((doc) => Certificate.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Certificate>> getAllCertificates() async {
    QuerySnapshot snapshot = await _certificatesCollection.get();
    return snapshot.docs
        .map((doc) => Certificate.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateCertificate(Certificate certificate) async {
    await _certificatesCollection
        .doc(certificate.id)
        .update(certificate.toJson());
  }

  Future<void> deleteCertificate(String certificateId) async {
    await _certificatesCollection.doc(certificateId).delete();
  }
}
