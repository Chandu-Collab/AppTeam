import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/address.dart';

class AddressService {
  final CollectionReference _addressesCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('users')
      .collection('addresses');

  Future<String> createAddress(Address address) async {
    DocumentReference docRef = await _addressesCollection.add(address.toJson());
    print("address: ${address.toJson()}, addressId generated: ${docRef.id}");
    return docRef.id;
  }

  Future<Address?> getAddress(String addressId) async {
    DocumentSnapshot doc = await _addressesCollection.doc(addressId).get();
    return doc.exists
        ? Address.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  Future<List<Address>> getAddressesForUser(String userId) async {
    QuerySnapshot snapshot =
        await _addressesCollection.where('userId', isEqualTo: userId).get();
    print("userId: ${userId}, addresses: ${snapshot.docs.length}");
    return snapshot.docs
        .map((doc) => Address.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateAddress(Address address) async {
    await _addressesCollection.doc(address.id).update(address.toJson());
  }

  Future<void> deleteAddress(String addressId) async {
    await _addressesCollection.doc(addressId).delete();
  }
}
