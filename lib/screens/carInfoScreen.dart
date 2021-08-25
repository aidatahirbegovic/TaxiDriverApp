import 'package:driver_app/screens/mainscreen.dart';
import 'package:driver_app/screens/registrationScreen.dart';
import 'package:driver_app/configMaps.dart';
import 'package:driver_app/widgets/customTextFieldRegistration.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/src/public_ext.dart';

import '../constants.dart';

class CarInfoScreen extends StatefulWidget {
  static const String idScreen = "car";

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  TextEditingController carModelTextEditingController = TextEditingController();

  TextEditingController carNumberTextEditingController =
      TextEditingController();

  TextEditingController carColorTextEditingController = TextEditingController();

  String carModel;

  String carNumber;

  String carColor;

  void saveDriverCarInfo() {
    String userId = currentFirebaseUser.uid;

    Map carInfoMap = {
      "car_color": carColor,
      "car_number": carNumber,
      "car_model": carModel,
    };

    driversRef.child(userId).child("car_details").set(carInfoMap);

    Navigator.pushNamedAndRemoveUntil(
        context, MainScreen.idScreen, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 22.0,
              ),
              Image.asset(
                "images/logo.png",
                width: 390.0,
                height: 250.0,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 32.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 12.0,
                    ),
                    Text(
                      'enter_car_details'.tr(),
                      style:
                          TextStyle(fontFamily: "Brand Bold", fontSize: 24.0),
                    ),
                    SizedBox(
                      height: 26.0,
                    ),
                    CustomTextField(
                      decoration: kRegisterTextFieldDecoration.copyWith(
                          labelText: 'car_model'.tr(),
                          prefixIcon: Icon(Icons.directions_car_rounded)),
                      obscureText: false,
                      onChange: (value) {
                        carModel = value;
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    CustomTextField(
                      decoration: kRegisterTextFieldDecoration.copyWith(
                          labelText: 'car_number'.tr(),
                          prefixIcon: Icon(Icons.directions_car_rounded)),
                      obscureText: false,
                      onChange: (value) {
                        carNumber = value;
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    CustomTextField(
                      decoration: kRegisterTextFieldDecoration.copyWith(
                          labelText: 'car_color'.tr(),
                          prefixIcon: Icon(Icons.directions_car_rounded)),
                      obscureText: false,
                      onChange: (value) {
                        carColor = value;
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (carModel.isEmpty) {
                            displayToastMessage(
                                'please_write'.tr() + 'car_model'.tr(),
                                context);
                          }
                          if (carNumber.isEmpty) {
                            displayToastMessage(
                                'please_write'.tr() + 'car_number'.tr(),
                                context);
                          }
                          if (carColor.isEmpty) {
                            displayToastMessage(
                                'please_write'.tr() + 'car_color'.tr(),
                                context);
                          } else {
                            saveDriverCarInfo();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Brand Bold",
                              color: Theme.of(context).accentColor),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all((17.0)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'next'.tr(),
                                style: kElevatedButtonTextStyle,
                              ),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.black,
                                size: 26.0,
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
