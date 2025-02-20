import 'package:flutter/material.dart';

Widget buildTextField(
    TextEditingController controller, String label, IconData icon,
    {int maxLines = 1, bool isNumeric = false, bool isPassword = false}) {
  return SizedBox(
    width: 300,
    child: TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      maxLines: maxLines,
      obscureText: isPassword,
      validator: (value) => value!.isEmpty ? "$label is required" : null,
    ),
  );
}
