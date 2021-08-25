import 'dart:async';

import 'package:driver_app/screens/registrationScreen.dart';
import 'package:driver_app/helpingMethods/assistantMethods.dart';
import 'package:driver_app/data/drivers.dart';
import 'package:driver_app/Notifications/pushNotificationService.dart';
import 'package:driver_app/configMaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:easy_localization/src/public_ext.dart';

import '../constants.dart';

class HomeTabPage extends StatefulWidget {
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  GoogleMapController newGoogleMapController;

  var geoLocator = Geolocator();

  String driverStatusText = "Offline now - Go Online ";

  Color driverStatusColor = Colors.black;

  bool isDriverAvailable = false;

  @override
  void initState() {
    super.initState();
    getCurrentDriverInfo();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    isDriverAvailable = false;
    makeDriverOfflineNow();
  }

  Future<void> locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    //String address = await AssistantMethods.searchCoordinateAddress(position, context);
    //print("This is your Address :: " + address);
  }

  Future<void> getCurrentDriverInfo() async {
    currentFirebaseUser = await FirebaseAuth.instance.currentUser;

    driversRef
        .child(currentFirebaseUser.uid)
        .once()
        .then((DataSnapshot dataSnapshot) {
      if (dataSnapshot != null) {
        driversInformation = Drivers.fromSnapshot(dataSnapshot);
      }
    });
    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize(context);
    pushNotificationService.getToken();

    AssistantMethods.retrieveHistoryInfo(context);
    getRatings();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: HomeTabPage._kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              locatePosition();
            },
          ),

          //online/offline driver
          Positioned(
            top: 5.0,
            left: 10.0,
            right: 350.0,
            child: Container(
              color: Colors.grey[50],
              width: 50.0,
              child: Switch(
                activeTrackColor: Colors.black45,
                activeColor: Colors.yellowAccent,
                inactiveThumbColor: Colors.black,
                value: isDriverAvailable,
                onChanged: (value) {
                  isDriverAvailable = value;

                  print(value);
                  if (isDriverAvailable) {
                    makeDriverOnlineNow();
                    getLocationLiveUpdate();
                    setState(() {
                      displayToastMessage("Online now", context);
                      driverStatusColor = Colors.green; //??
                      driverStatusText = "Online now";
                    });
                  } else {
                    makeDriverOfflineNow();
                    setState(() {
                      driverStatusText = "Offline now - Go Online";
                      driverStatusColor = Colors.black;
                    });
                  }
                },
              ),
            ),
            // child: Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 16.0),
            //       child: ElevatedButton(
            //         onPressed: () {
            //           if (isDriverAvailable != true) {
            //             makeDriverOnlineNow();
            //             getLocationLiveUpdate();
            //
            //             setState(() {
            //               driverStatusColor = Colors.green; //??
            //               driverStatusText = "Online now";
            //               isDriverAvailable = true;
            //             });
            //
            //             displayToastMessage("Online now", context);
            //           } else {
            //             makeDriverOfflineNow();
            //
            //             setState(() {
            //               driverStatusColor = Colors.black; //??
            //               driverStatusText = "Offline now - Go Online";
            //               isDriverAvailable = false;
            //             });
            //
            //             displayToastMessage("Offline now", context);
            //           }
            //         },
            //         style: ElevatedButton.styleFrom(
            //           textStyle: TextStyle(
            //             fontSize: 18.0,
            //             fontFamily: "Brand Bold",
            //             color: Colors.green,
            //           ),
            //         ),
            //         child: Padding(
            //           padding: EdgeInsets.all((17.0)),
            //           child: Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             children: [
            //               Text(
            //                 driverStatusText,
            //                 style: TextStyle(
            //                     fontSize: 20.0,
            //                     fontWeight: FontWeight.bold,
            //                     color: Colors.white),
            //               ),
            //               Icon(
            //                 Icons.phone_android,
            //                 color: Colors.white,
            //                 size: 26.0,
            //               )
            //             ],
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          )
        ],
      ),
    );
  }

  getRatings() {
    //ratings updated
    driversRef
        .child(currentFirebaseUser.uid)
        .child("ratings")
        .once()
        .then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        double ratings = double.parse(dataSnapshot.value.toString());
        setState(() {
          starCounter = ratings;
        });

        if (starCounter <= 1.5) {
          setState(() {
            title = 'very_bad'.tr();
          });
          return;
        }
        if (starCounter <= 2.5) {
          setState(() {
            title = 'bad'.tr();
          });

          return;
        }
        if (starCounter <= 3.5) {
          setState(() {
            title = 'good'.tr();
          });

          return;
        }
        if (starCounter <= 4.5) {
          setState(() {
            title = 'very_good'.tr();
          });
          return;
        }
        if (starCounter <= 5.0) {
          setState(() {
            title = 'excellent'.tr();
          });

          return;
        }
      }
    });
  }

  void makeDriverOnlineNow() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    Geofire.initialize("availableDrivers");
    Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude,
        currentPosition.longitude);

    rideRequestRef
        .set("searching"); //driver is available, can accept ride request
    rideRequestRef.onValue.listen((event) {});
  }

  void getLocationLiveUpdate() {
    homeTabPageStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      if (isDriverAvailable == true) {
        Geofire.setLocation(
            currentFirebaseUser.uid, position.latitude, position.longitude);
      }

      LatLng latLng = LatLng(position.latitude, position.longitude);
      newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void makeDriverOfflineNow() {
    Geofire.removeLocation(currentFirebaseUser.uid);
    rideRequestRef.onDisconnect();
    rideRequestRef.remove();
    rideRequestRef = null;
  }
}
