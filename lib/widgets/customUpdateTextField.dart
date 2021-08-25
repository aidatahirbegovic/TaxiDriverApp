import 'package:flutter/material.dart';

class CustomUpdateTextField extends StatelessWidget {
  CustomUpdateTextField(
      {this.decoration, this.obscureText, this.onChange, this.value});

  final decoration;
  final obscureText;
  final Function onChange;
  final value;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      keyboardType: TextInputType.text,
      decoration: decoration,
      obscureText: obscureText,
      cursorColor: Colors.orange,
      style: TextStyle(fontSize: 14.0, color: Colors.black87),
      onChanged: onChange,
    );
  }
}
