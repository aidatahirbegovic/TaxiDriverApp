import 'package:flutter/material.dart';

class ProgressDialog extends StatefulWidget {
  final String message;
  ProgressDialog({this.message});

  @override
  State<ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.yellow,
      child: Container(
        margin: EdgeInsets.all(15.0),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(6.0)),
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: [
              SizedBox(
                width: 6.0,
              ),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
              SizedBox(
                width: 6.0,
              ),
              Text(
                widget.message,
                style: TextStyle(color: Colors.black, fontSize: 10.0),
              )
            ],
          ),
        ),
      ),
    );
  }
}
