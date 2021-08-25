import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField({this.decoration, this.obscureText, this.onChange});

  final decoration;
  final obscureText;
  final Function onChange;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.text,
      decoration: decoration,
      obscureText: obscureText,
      cursorColor: Colors.orange,
      style: TextStyle(fontSize: 14.0, color: Colors.black87),
      onChanged: onChange,
    );
  }
}
