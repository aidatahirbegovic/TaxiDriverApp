import 'package:driver_app/widgets/customUpdateTextField.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_localization/src/public_ext.dart';

import '../configMaps.dart';
import '../constants.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  String password;
  String cPassword;
  String passwordOld;

  void _update() {
    driversRef.child(userCurrentInfo.id).child("password").set(password);
    displayToastMessage('password_changed'.tr(), context);
    Navigator.pop(context);
  }

  bool comparePasswords() {
    if (password.compareTo(cPassword) == 0)
      return true;
    else
      return false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20.0,
                    ),
                    Container(
                      height: 80.0,
                      child: Image.asset("images/logo.png"),
                    ),
                    SizedBox(
                      width: 1.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0, left: 10.0),
                      child: Text(
                        'change_password'.tr(),
                        style: kText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 1.0,
                    ),
                    CustomUpdateTextField(
                      decoration: kRegisterTextFieldDecoration.copyWith(
                          labelText: 'password'.tr(),
                          prefixIcon: Icon(Icons.password_rounded)),
                      obscureText: true,
                      onChange: (value) {
                        password = value;
                      },
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    CustomUpdateTextField(
                      decoration: kRegisterTextFieldDecoration.copyWith(
                          labelText: 'confirm_password'.tr(),
                          prefixIcon: Icon(Icons.password_rounded)),
                      obscureText: true,
                      onChange: (value) {
                        cPassword = value;
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.yellow,
                        textStyle: kElevatedButtonTextStyle,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(24.0)),
                      ),
                      onPressed: () {
                        print('onpressed elevated button');
                        if (comparePasswords()) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.black45,
                                title: Text(
                                  'password'.tr(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.yellowAccent),
                                ),
                                content: TextField(
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    labelText: 'enter_password'.tr(),
                                    labelStyle: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.yellowAccent,
                                    ),
                                    hintStyle:
                                        TextStyle(color: Colors.yellowAccent),
                                    prefixIcon: Icon(
                                      Icons.password,
                                      color: Colors.yellowAccent,
                                    ),
                                  ),
                                  obscureText: true,
                                  cursorColor: Colors.orange,
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.yellowAccent),
                                  onChanged: (value) {
                                    passwordOld = value;
                                  },
                                ),
                                actions: [
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        child: Text('cancel'.tr()),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        style: ButtonStyle(),
                                      ),
                                      ElevatedButton(
                                        child: Text('OK'),
                                        onPressed: () async {
                                          String userPassword;
                                          await driversRef
                                              .child(userCurrentInfo.id)
                                              .child("password")
                                              .once()
                                              .then((DataSnapshot snapshot) {
                                            userPassword = snapshot.value;
                                          });
                                          print(userPassword);
                                          print(passwordOld);
                                          if (passwordOld
                                                  .compareTo(userPassword) ==
                                              0) {
                                            _update();
                                          } else {
                                            displayToastMessage(
                                                'password_enter'.tr(), context);
                                          }
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          displayToastMessage(
                              'passwords_not_match'.tr(), context);
                        }
                      },
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text('change_password'.tr()),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
