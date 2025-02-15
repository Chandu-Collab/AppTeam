import 'package:flutter/material.dart';
import 'package:taurusai/models/address.dart';
import 'package:taurusai/screens/add_address_screen.dart';
import 'package:taurusai/services/add_address_service.dart';

class AddressListPage extends StatefulWidget {
  final String userId;

  AddressListPage({required this.userId});

  @override
  _AddressListPageState createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  final AddressService _addressService = AddressService();

  late Future<List<Address>> _addressesFuture;

  @override
  void initState() {
    super.initState();
    _addressesFuture = _addressService.getAddresses(widget.userId);
  }

  Future<void> deleteAddress(String addressId) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Address"),
          content: Text("Are you sure you want to delete this address?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _addressService.deleteAddress(widget.userId, addressId);
      setState(() {
        _addressesFuture = _addressService.getAddresses(widget.userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Address List", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<Address>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Colors.orange));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Failed to load addresses."));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No addresses found."));
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final address = snapshot.data![index];
                return Container(
                  margin: EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(15),
                    title: Text(
                      "${address.street}, ${address.city}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${address.state}, ${address.country} - ${address.postalCode}"
                      "${address.additionalInfo != null ? '\n${address.additionalInfo}' : ''}",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.orange),
                          onPressed: () async => await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddressFormScreen(addressId: address.id),
                            ),
                          ).then((_) {
                            setState(() {
                              _addressesFuture =
                                  _addressService.getAddresses(widget.userId);
                            });
                          }),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteAddress(address.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddressFormScreen()),
        ),
      ),
    );
  }
}
