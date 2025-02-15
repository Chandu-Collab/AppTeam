 import 'package:flutter/material.dart';

  Widget buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isNumeric = false}) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(icon),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        validator: (value) => value!.isEmpty ? "$label is required" : null,
      ),
    );
  }
