import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:taurusai/models/address.dart';
import 'package:taurusai/services/add_address_service.dart';
import 'package:taurusai/widgets/input_widget.dart';
import 'package:taurusai/widgets/button_widget.dart';
//  code to get the current user id

String? getCurrentUserId() {
  final auth.User? user = auth.FirebaseAuth.instance.currentUser;
  return user?.uid;
}

void main() {
  runApp(MaterialApp(
    home: AddressFormScreen(),
  ));
}

class AddressFormScreen extends StatefulWidget {
  final String? addressId;

  AddressFormScreen({this.addressId});

  @override
  _AddressFormScreenState createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String street = '';
  String city = ''; // Add city field
  String state = ''; // Add state field
  String country = ''; // Add country field
  String postalCode = ''; // Add postalCode field
  String additionalInfo = ''; // Add additionalInfo field
  final AddressService _addressService = AddressService();

  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _additionalInfoController =
      TextEditingController();

  String? _selectedCountry;
  bool _isEditing = false;
  @override
  void initState() {
    super.initState();
    if (widget.addressId != null) {
      _loadAddressData();
    }
  }

  Future<void> _loadAddressData() async {
    String? userId = getCurrentUserId();
    if (userId != null && widget.addressId != null) {
      Address? address =
          await _addressService.getAddress(userId, widget.addressId!);
      if (address != null) {
        setState(() {
          _streetController.text = address.street;
          _cityController.text = address.city;
          _stateController.text = address.state;
          _selectedCountry = address.country;
          _postalCodeController.text = address.postalCode;
          _additionalInfoController.text = address.additionalInfo ?? '';
          _isEditing = true;
        });
      }
    }
  }

  void _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      String? userId = getCurrentUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in")),
        );
        return;
      }

      Address newAddress = Address(
        id: widget.addressId ?? '',
        street: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        country: _selectedCountry!,
        postalCode: _postalCodeController.text,
        additionalInfo: _additionalInfoController.text,
        userId: userId, // Add userId here
      );

      try {
        if (_isEditing) {
          await _addressService.updateAddress(userId, newAddress);
        } else {
          await _addressService.createAddress(userId, newAddress);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Address saved successfully!")),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save address: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome!",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("Fill in your address details",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildTextField(
                        "Street Address",
                        _streetController,
                        (value) => value!.isEmpty
                            ? "Street Address is required"
                            : null,
                        (value) => street = value!,
                      ),
                      SizedBox(height: 12),
                      buildTextField(
                        "City",
                        _cityController,
                        (value) => value!.isEmpty ? "City is required" : null,
                        (value) => city = value!,
                        icon: Icons.location_city,
                      ),
                      SizedBox(height: 16),
                      buildTextField(
                        "State",
                        _stateController,
                        (value) => value!.isEmpty ? "State is required" : null,
                        (value) => state = value!,
                        icon: Icons.location_on,
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: 300,
                        child: DropdownButtonFormField<String>(
                          value: _selectedCountry,
                          decoration: _inputDecoration("Country", Icons.flag),
                          items: ["USA", "Canada", "UK", "Australia", "India"]
                              .map((country) => DropdownMenuItem(
                                    value: country,
                                    child: Text(country),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedCountry = value),
                          validator: (value) =>
                              value == null ? "Select a country" : null,
                        ),
                      ),
                      SizedBox(height: 12),
                      buildTextField(
                        "Postal Code",
                        _postalCodeController,
                        (value) =>
                            value!.isEmpty ? "Postal Code is required" : null,
                        (value) => postalCode = value!,
                        icon: Icons.location_on,
                      ),
                      SizedBox(height: 16),
                      buildTextField(
                        "Additional Info (Optional)",
                        _additionalInfoController,
                        (value) => null,
                        (value) => additionalInfo = value!,
                        icon: Icons.info_outline,
                      ),
                      SizedBox(height: 20),
                      buildButton(_saveAddress, text: "Save Address"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIcon: Icon(icon),
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }
}
