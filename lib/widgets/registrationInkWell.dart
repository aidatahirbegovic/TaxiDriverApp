import 'package:flutter/material.dart';

class RegistrationInkWell extends StatelessWidget {
  RegistrationInkWell({this.function, this.text, this.icon});

  final Function function;
  final icon;
  final text;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: function,
      splashColor: Colors.yellowAccent,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              color: Colors.yellowAccent,
            ),
          ),
          Text(
            text,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.yellowAccent),
          ),
        ],
      ),
    );
  }
}
