import 'package:flutter/material.dart';

Widget buildButton(onPressedMethod, {String? text}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minimumSize: Size(double.infinity, 50),
    ),
    onPressed: onPressedMethod,
    child: Text(text ?? "Submit",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  );
}
