import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'configMaps.dart';

DatabaseReference usersRef =
    FirebaseDatabase.instance.reference().child("users");
DatabaseReference driversRef =
    FirebaseDatabase.instance.reference().child("drivers");
DatabaseReference newRequestRef =
    FirebaseDatabase.instance.reference().child("Ride Requests");
DatabaseReference rideRequestRef = FirebaseDatabase.instance
    .reference()
    .child("drivers")
    .child(currentFirebaseUser.uid)
    .child("newRide");

const kText = TextStyle(fontSize: 24.0, fontFamily: "Brand Bold");

const kRegisterTextFieldDecoration = InputDecoration(
  labelText: "Name",
  labelStyle: TextStyle(
    fontSize: 14.0,
    color: Colors.black,
  ),
  hintStyle: TextStyle(color: Colors.grey),
  prefixIcon: Icon(Icons.person),
);

const kElevatedButtonTextStyle =
    TextStyle(fontSize: 18.0, fontFamily: "Brand Bold", color: Colors.black);

const kTextFieldInputDecoration = InputDecoration(
  hintText: 'Enter your email',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.yellowAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.yellowAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const kTextButtonStyle = TextStyle(color: Colors.black);
