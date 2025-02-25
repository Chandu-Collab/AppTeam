import 'package:flutter/material.dart';

Widget buildTextField(
    String label,
    TextEditingController controller,
    String? Function(String?)? validator,
    void Function(String?) onSaved,
    {IconData? icon, int maxLines = 1, 
    bool isNumeric = false, bool isPassword = false, bool readOnly = false, void Function()? onTap}) {
  return SizedBox(
    width: double.infinity,
    child: TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: icon != null ? Icon(icon) : null,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      maxLines: maxLines,
      obscureText: isPassword,
      validator: validator,
      onSaved: onSaved,
      readOnly: readOnly,
      onTap: onTap,
    ),
  );
}