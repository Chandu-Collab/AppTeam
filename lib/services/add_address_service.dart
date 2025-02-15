import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/address.dart';

class AddressService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('users')
      .collection('profiles');

  Future<String> addAddress(String userId, Address address) async {
    // Create a new document reference
    DocumentReference docRef =
        _usersCollection.doc(userId).collection('addresses').doc();

    // Set the document ID inside the address object
    address.id = docRef.id;

    // Save address with the correct ID in Firestore
    await docRef.set(address.toJson());

    return docRef.id;
  }

  Future<List<Address>> getAddresses(String userId) async {
    QuerySnapshot snapshot =
        await _usersCollection.doc(userId).collection('addresses').get();

    return snapshot.docs
        .map((doc) => Address.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<Address?> getAddress(String userId, String addressId) async {
    DocumentSnapshot doc = await _usersCollection
        .doc(userId)
        .collection('addresses')
        .doc(addressId)
        .get();

    return doc.exists
        ? Address.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  Future<void> updateAddress(
      String userId, String addressId, Address address) async {
    await _usersCollection
        .doc(userId)
        .collection('addresses')
        .doc(addressId)
        .update(address.toJson());
  }

  Future<void> deleteAddress(String userId, String addressId) async {
    await _usersCollection
        .doc(userId)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }

  Future<void> deleteAllAddresses(String userId) async {
    QuerySnapshot snapshot =
        await _usersCollection.doc(userId).collection('addresses').get();

    for (DocumentSnapshot doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
