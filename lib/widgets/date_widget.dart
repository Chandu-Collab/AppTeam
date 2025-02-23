import 'package:flutter/material.dart';

Widget buildDateField(
  String label,
  TextEditingController controller,
  VoidCallback onTap, {
  String? Function(String?)? validator,
}) {
  return SizedBox(
    width: 300,
    child: TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: Icon(Icons.calendar_today),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      validator: validator,
      onTap: onTap,
    ),
  );
}