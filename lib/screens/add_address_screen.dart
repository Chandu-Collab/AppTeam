import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:taurusai/models/address.dart';
import 'package:taurusai/services/add_address_service.dart';

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
      Address? address = await _addressService.getAddress(widget.addressId!);
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
      );

      try {
        if (_isEditing) {
          await _addressService.updateAddress(newAddress);
        } else {
          await _addressService.createAddress(newAddress);
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
                      _buildTextField(_streetController, "Street Address"),
                      _buildTextField(_cityController, "City"),
                      _buildTextField(_stateController, "State"),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCountry,
                              decoration: _inputDecoration("Country"),
                              items: [
                                "USA",
                                "Canada",
                                "UK",
                                "Australia",
                                "India"
                              ]
                                  .map((country) => DropdownMenuItem(
                                      value: country, child: Text(country)))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedCountry = value),
                              validator: (value) =>
                                  value == null ? "Select a country" : null,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                                _postalCodeController, "Postal Code",
                                isNumber: true),
                          ),
                        ],
                      ),
                      _buildTextField(_additionalInfoController,
                          "Additional Info (Optional)",
                          maxLines: 3),
                      SizedBox(height: 20),
                      _buildSubmitButton(),
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

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: _inputDecoration(label),
        validator: (value) =>
            value == null || value.isEmpty ? "$label is required" : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: Size(double.infinity, 50),
      ),
      onPressed: _saveAddress,
      child: Text("Save Address",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
