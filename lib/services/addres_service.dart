import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/address.dart';

class AddressService {
  final CollectionReference _addressesCollection = FirebaseFirestore.instance
      .collection('taurusai')
      .doc('users')
      .collection('addresses');

  Future<String> createAddress(Address address) async {
    DocumentReference docRef = await _addressesCollection.add(address.toJson());
    return docRef.id;
  }

  Future<Address?> getAddress(String addressId) async {
    DocumentSnapshot doc = await _addressesCollection.doc(addressId).get();
    return doc.exists
        ? Address.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  Future<List<Address>> getAddressesByUserId(String userId) async {
    QuerySnapshot snapshot =
        await _addressesCollection.where('userId', isEqualTo: userId).get();
    return snapshot.docs
        .map((doc) => Address.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Address>> getAddressesByFilter(
      {String? city, String? state, String? country}) async {
    Query query = _addressesCollection;

    if (city != null && city.isNotEmpty) {
      query = query.where('city', isEqualTo: city);
    }
    if (state != null && state.isNotEmpty) {
      query = query.where('state', isEqualTo: state);
    }
    if (country != null && country.isNotEmpty) {
      query = query.where('country', isEqualTo: country);
    }

    QuerySnapshot snapshot = await query.get();
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
