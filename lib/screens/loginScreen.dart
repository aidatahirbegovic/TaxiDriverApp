import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:driver_app/screens/mainscreen.dart';
import 'package:driver_app/screens/registrationScreen.dart';
import 'package:driver_app/widgets/progressDialog.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:easy_localization/src/public_ext.dart';

import '../constants.dart';

class LoginScreen extends StatefulWidget {
  static const String idScreen = "login_screen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();

  TextEditingController passwordTextEditingController = TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String email;
  String password;

  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: ModalProgressHUD(
            inAsyncCall: showSpinner,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    child: Hero(
                      tag: 'logo',
                      child: Container(
                        height: 200.0,
                        child: Image.asset("images/logo.png"),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    'login'.tr(),
                    style: kText,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextField(
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: kTextFieldInputDecoration.copyWith(
                        hintText: 'enter_email'.tr()),
                    style: TextStyle(fontSize: 14.0),
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      email = value;
                    },
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    controller: passwordTextEditingController,
                    obscureText: true,
                    decoration: kTextFieldInputDecoration.copyWith(
                        hintText: 'enter_password'.tr()),
                    style: TextStyle(fontSize: 14.0),
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      password = value;
                    },
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.yellow,
                      textStyle: kElevatedButtonTextStyle,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(24.0)),
                    ),
                    onPressed: () async {
                      setState(() {
                        showSpinner = true;
                      });

                      // if (!emailTextEditingController.text.contains("@")) {
                      //   displayToastMessage(
                      //       "Email address is not valid", context);
                      // } else if (passwordTextEditingController.text.isEmpty) {
                      //   displayToastMessage("Password is mandatory", context);
                      // } else {
                      //   //loginAndAuthenticateUser(context);
                      // }
                      try {
                        final user =
                            await _firebaseAuth.signInWithEmailAndPassword(
                                email: email, password: password);

                        if (user != null) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, MainScreen.idScreen, (route) => false);
                        } else
                          Navigator.pop(context);
                        setState(() {
                          showSpinner = false;
                        });
                      } catch (e) {
                        setState(() {
                          showSpinner = false;
                        });
                        displayToastMessage(
                            'check_email_password'.tr(), context);
                      }
                    },
                    child: Container(
                      height: 50.0,
                      child: Center(
                        child: Text('login_button'.tr()),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context,
                          RegistrationScreen.idScreen, (route) => false);
                    },
                    child: Text(
                      'no_account'.tr(),
                      style: kTextButtonStyle,
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  // void loginAndAuthenticateUser(BuildContext context) async {
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return ProgressDialog(
  //           message: "Authenticating, Please wait...",
  //         );
  //       });
  //
  //   final User firebaseUser = (await _firebaseAuth
  //           .signInWithEmailAndPassword(email: email, password: password)
  //           .catchError((errMsg) {
  //     Navigator.pop(context);
  //     displayToastMessage("Error: " + errMsg.toString(), context);
  //   }))
  //       .user;
  //
  //   if (firebaseUser != null) {
  //     driversRef.child(firebaseUser.uid).once().then((DataSnapshot snap) {
  //       //login kao driver, ne moze se svaki user pijaviti kao driver
  //       if (snap.value != null) {
  //         //user is in database
  //         Navigator.pushNamedAndRemoveUntil(
  //             context, MainScreen.idScreen, (route) => false);
  //         displayToastMessage("You are logged-in", context);
  //       } else {
  //         Navigator.pop(context);
  //         _firebaseAuth.signOut();
  //         displayToastMessage(
  //             "No record exists for this user. Please create new account",
  //             context);
  //       }
  //     });
  //   } else {
  //     Navigator.pop(context);
  //     displayToastMessage("Error occured.", context);
  //   }
  // }
}
