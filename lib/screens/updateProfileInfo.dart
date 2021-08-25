import 'dart:io';

import 'package:driver_app/helpingMethods/assistantMethods.dart';
import 'package:driver_app/screens/changePassword.dart';
import 'package:driver_app/widgets/customUpdateTextField.dart';
import 'package:driver_app/widgets/registrationInkWell.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/src/public_ext.dart';

import '../configMaps.dart';
import '../constants.dart';

class UpdateInfo extends StatefulWidget {
  @override
  _UpdateInfoState createState() => _UpdateInfoState();
}

class _UpdateInfoState extends State<UpdateInfo> {
  File _imageFile;
  String name;
  String email;
  String phone;
  String password;
  String imageUrl;

  Future<void> currentOnlineUser() async {
    AssistantMethods.getCurrentOnlineUserInfo();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentOnlineUser();
  }

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

  void update() async {
    if (_imageFile != null) {
      String imageFileName = DateTime.now()
          .millisecondsSinceEpoch
          .toString(); //this will give us unique string
      try {
        var imageFile =
            FirebaseStorage.instance.ref().child(imageFileName).child("/.jpg");
        UploadTask task = imageFile.putFile(_imageFile);
        TaskSnapshot snapshot = await task;
        imageUrl = await snapshot.ref.getDownloadURL();
      } on FirebaseException catch (e) {
        print(e);
      }
    }

    if (name != null) {
      if (name.length < 4) {
        displayToastMessage('username_4_ch'.tr(), context);
      } else {
        driversRef.child(userCurrentInfo.id).child("name").set(name);
      }
    }
    if (email != null) {
      driversRef.child(userCurrentInfo.id).child("email").set(email);
    }
    if (phone != null) {
      driversRef.child(userCurrentInfo.id).child("phone").set(phone);
    }
    displayToastMessage('updated'.tr(), context);
    Navigator.pop(context);
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
                        'update_info'.tr(),
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
                              backgroundImage: userCurrentInfo == null
                                  ? null
                                  : NetworkImage(userCurrentInfo.imageUrl),
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
                    CustomUpdateTextField(
                      value: userCurrentInfo.name,
                      decoration: kRegisterTextFieldDecoration.copyWith(
                        labelText: 'name'.tr(),
                      ),
                      obscureText: false,
                      onChange: (value) {
                        name = value;
                      },
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    CustomUpdateTextField(
                      value: userCurrentInfo.email,
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
                    CustomUpdateTextField(
                      value: userCurrentInfo.phone,
                      decoration: kRegisterTextFieldDecoration.copyWith(
                          labelText: 'phone'.tr(),
                          prefixIcon: Icon(Icons.phone)),
                      obscureText: false,
                      onChange: (value) {
                        phone = value;
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
                                    fontSize: 14.0, color: Colors.yellowAccent),
                                onChanged: (value) {
                                  password = value;
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
                                        print(password);
                                        if (password.compareTo(userPassword) ==
                                            0) {
                                          update();
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
                      },
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text('update_account'.tr()),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.yellow,
                        textStyle: kElevatedButtonTextStyle,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(24.0)),
                      ),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangePassword())),
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

  TextEditingController _textFieldController = TextEditingController();

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            'Password',
            style: TextStyle(color: Colors.yellowAccent),
          ),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Text Field in Dialog"),
          ),
          actions: [
            ElevatedButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                print(_textFieldController.text);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
