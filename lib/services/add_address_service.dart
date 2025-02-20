import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taurusai/models/address.dart';

class AddressService {
  /// Returns the reference to the addresses collection for a specific user
  CollectionReference _addressesCollection(String userId) =>
      FirebaseFirestore.instance
          .collection('taurusai')
          .doc(userId)
          .collection('addresses');

  /// Create a new address for a specific user
  Future<String> createAddress(String userId, Address address) async {
    DocumentReference docRef =
        _addressesCollection(userId).doc(); // Generate a new document reference
    address.id = docRef.id; // Assign the generated ID to the address
    await docRef.set(address
        .toJson()); // Use set() instead of add() to ensure the ID is stored
    print('Address created with ID: ${docRef.id}');
    return docRef.id;
  }

  /// Retrieve a single address by ID for a specific user
  Future<Address?> getAddress(String userId, String addressId) async {
    DocumentSnapshot doc =
        await _addressesCollection(userId).doc(addressId).get();
    return doc.exists
        ? Address.fromJson(doc.data() as Map<String, dynamic>)
        : null;
  }

  /// Retrieve all addresses for a specific user
  Future<List<Address>> getAddressesForUser(String userId) async {
    QuerySnapshot snapshot = await _addressesCollection(userId).get();
    print("Total addresses: ${snapshot.docs.length}");
    return snapshot.docs
        .map((doc) => Address.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Update an existing address for a specific user
  Future<void> updateAddress(String userId, Address address) async {
    await _addressesCollection(userId).doc(address.id).update(address.toJson());
  }

  /// Delete an address by ID for a specific user
  Future<void> deleteAddress(String userId, String addressId) async {
    await _addressesCollection(userId).doc(addressId).delete();
  }

  // Delete all addresses for a specific user
  Future<void> deleteAllAddresses(String userId) async {
    QuerySnapshot snapshot = await _addressesCollection(userId).get();

    for (DocumentSnapshot doc in snapshot.docs) {
      await doc.reference.delete();
    }

    print("All addresses deleted for user: $userId");
  }
}
