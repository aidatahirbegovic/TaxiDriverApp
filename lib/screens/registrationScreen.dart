import 'dart:io';

import 'package:driver_app/screens/carInfoScreen.dart';
import 'package:driver_app/configMaps.dart';
import 'package:driver_app/widgets/customTextFieldRegistration.dart';
import 'package:driver_app/widgets/registrationInkWell.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:driver_app/widgets/progressDialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/src/public_ext.dart';

import '../constants.dart';

class RegistrationScreen extends StatefulWidget {
  static const String idScreen = "register_screen";

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController nameTextEditingController = TextEditingController();

  TextEditingController emailTextEditingController = TextEditingController();

  TextEditingController phoneTextEditingController = TextEditingController();

  TextEditingController passwordTextEditingController = TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  File _imageFile;
  String name;
  String email;
  String phone;
  String password;
  String cPassword;
  String driverImageUrl;

  void _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _imageFile = pickedImageFile;
    });
    Navigator.pop(context);
  }

  void _remove() {
    setState(() {
      _imageFile = null;
    });
    Navigator.pop(context);
  }

  Future<void> _uploadAndSaveImage() async {
    if (_imageFile == null) {
      showDialog(
          context: context,
          builder: (c) {
            return AlertDialog(
              content: Text('select_image'.tr()),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          });
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ProgressDialog(
              message: 'registering_dialog'.tr(),
            );
          });
      password == cPassword
          ? email.isNotEmpty &&
                  password.isNotEmpty &&
                  cPassword.isNotEmpty &&
                  name.isNotEmpty
              ? _uploadToStorage()
              : displayDialog(context, 'fill_registration_form'.tr())
          : displayDialog(context, 'passwords_not_match'.tr());
    }
  }

  Future<void> _uploadToStorage() async {
    String imageFileName = DateTime.now()
        .millisecondsSinceEpoch
        .toString(); //this will give us unique string

    try {
      var imageFile =
          FirebaseStorage.instance.ref().child(imageFileName).child("/.jpg");
      UploadTask task = imageFile.putFile(_imageFile);
      TaskSnapshot snapshot = await task;
      driverImageUrl = await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      print(e);
    }

    //print(userImageUrl + ' is image url');
    _registerNewUser();
  }

  void _registerNewUser() async {
    final User firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password)
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToastMessage(
          'error_message_print'.tr() + errMsg.toString(), context);
    }))
        .user;

    if (firebaseUser != null) {
      //user created
      //save user into database

      Map userDataMap = {
        "name": name,
        "email": email,
        "phone": phone,
        "password": password,
        "driverImageUrl": driverImageUrl,
      };

      driversRef.child(firebaseUser.uid).set(userDataMap);

      currentFirebaseUser = firebaseUser;
      displayToastMessage('account_created'.tr(), context);
      Navigator.pushNamed(context, CarInfoScreen.idScreen);
    } else {
      Navigator.pop(context);
      displayToastMessage('account_not_created'.tr(), context);
    }
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
                        'register'.tr(),
                        style: kText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 30),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.black87,
                            child: CircleAvatar(
                              radius: 54,
                              backgroundImage: _imageFile == null
                                  ? null
                                  : FileImage(_imageFile),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 100,
                          left: 80,
                          child: RawMaterialButton(
                            elevation: 10,
                            fillColor: Colors.yellowAccent,
                            child: Icon(Icons.add_a_photo),
                            padding: EdgeInsets.all(15.0),
                            shape: CircleBorder(),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.black54,
                                      title: Text(
                                        'choose_option'.tr(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.yellowAccent),
                                      ),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: [
                                            RegistrationInkWell(
                                              function: () => _pickImage(
                                                  ImageSource.camera),
                                              icon: Icons.camera,
                                              text: 'camera'.tr(),
                                            ),
                                            RegistrationInkWell(
                                              function: () => _pickImage(
                                                  ImageSource.gallery),
                                              icon: Icons.image,
                                              text: 'gallery'.tr(),
                                            ),
                                            RegistrationInkWell(
                                              function: () => _remove(),
                                              icon: Icons.remove_circle,
                                              text: 'remove'.tr(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    CustomTextField(
                      decoration: kRegisterTextFieldDecoration.copyWith(
                          labelText: 'name'.tr()),
                      obscureText: false,
                      onChange: (value) {
                        name = value;
                      },
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    CustomTextField(
                      decoration: kRegisterTextFieldDecoration.copyWith(
                          labelText: 'email'.tr(),
                          prefixIcon: Icon(Icons.email)),
                      obscureText: false,
                      onChange: (value) {
                        email = value;
                      },
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    CustomTextField(
                      decoration: kRegisterTextFieldDecoration.copyWith(
                          labelText: 'phone'.tr(),
                          prefixIcon: Icon(Icons.phone)),
                      obscureText: false,
                      onChange: (value) {
                        phone = value;
                      },
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    CustomTextField(
                      decoration: kRegisterTextFieldDecoration.copyWith(
                          labelText: 'password'.tr(),
                          prefixIcon: Icon(Icons.password)),
                      obscureText: true,
                      onChange: (value) {
                        password = value;
                      },
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    CustomTextField(
                      decoration: kRegisterTextFieldDecoration.copyWith(
                          labelText: 'confirm_password'.tr(),
                          prefixIcon: Icon(Icons.password)),
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
                        if (name.length < 4) {
                          displayToastMessage('username_4_ch'.tr(), context);
                        } else if (!email.contains("@")) {
                          displayToastMessage('email_validation'.tr(), context);
                        } else if (phone.isEmpty) {
                          displayToastMessage('phone_not_empty'.tr(), context);
                        } else if (password.length < 6) {
                          displayToastMessage('password_check'.tr(), context);
                        } else {
                          _uploadAndSaveImage();
                        }
                      },
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            'create_account'.tr(),
                          ),
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

  displayDialog(BuildContext context, String msg) {
    showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            content: Text(msg),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        });
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
