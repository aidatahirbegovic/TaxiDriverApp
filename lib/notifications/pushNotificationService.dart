import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:driver_app/data/rideDetails.dart';
import 'package:driver_app/configMaps.dart';
import 'package:driver_app/notifications/notificationDialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants.dart';

class PushNotificationService {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  Future initialize(context) async {
    if (Platform.isIOS) {
      firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }
    // await FirebaseMessaging.instance.getToken(); // Add this line
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Got a message whilst in the foreground!');
    //   print('Message data: ${message.data}');
    //
    //   if (message.notification != null) {
    //     print('Message also contained a notification: ${message.notification}');
    //   }
    // });
    //onMessage
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      retrieveRideRequestInfo(getRideRequestId(message.data), context);
    });

    //onResume
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      retrieveRideRequestInfo(getRideRequestId(message.data), context);
    });

    //onLaunch
    final RemoteMessage initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      retrieveRideRequestInfo(getRideRequestId(initialMessage.data), context);
    }

    // NotificationSettings settings = firebaseMessaging.requestPermission(
    //   sound: true,
    //   badge: true,
    //   alert: true,
    //   provisional: true,
    // );
  }

  // final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  // Future initialize(context) async {
  //   firebaseMessaging.configure(
  //     onMessage: (Map<String, dynamic> message) async {
  //       //when driver app has been open
  //       retriveRideRequestInfo(getRideRequestId(message), context);
  //     },
  //     onLaunch: (Map<String, dynamic> message) async {
  //       //when driver opens notification to accept or decline request
  //       retriveRideRequestInfo(getRideRequestId(message), context);
  //     },
  //     onResume: (Map<String, dynamic> message) async {
  //       //app is minimized, app is running in background
  //       retriveRideRequestInfo(getRideRequestId(message), context);
  //     },
  //   );
  // }

  Future<void> getToken() async {
    String token = await firebaseMessaging.getToken();
    print("This is token ::");
    print(token);
    driversRef.child(currentFirebaseUser.uid).child("token").set(token);

    firebaseMessaging.subscribeToTopic("alldrivers");
    firebaseMessaging.subscribeToTopic("allusers");
  }

  String getRideRequestId(Map<String, dynamic> message) {
    String rideRequestId;
    if (Platform.isAndroid) {
      print("This is android request id ::");
      rideRequestId = message['ride_request_id'];
      print(rideRequestId);
    } else {
      print("This is android request id ::");
      rideRequestId = message['ride_request_id'];
      print(rideRequestId);
    }
    return rideRequestId;
  }

  void retrieveRideRequestInfo(
      String rideRequestId, BuildContext context) async {
    RideDetails rideDetails = RideDetails();
    String imageUrl;
    String userName;
    String phone;

    await newRequestRef
        .child(rideRequestId)
        .once()
        .then((DataSnapshot dataSnapShot) {
      if (dataSnapShot.value != null) {
        assetsAudioPlayer.open((Audio("sounds/alert.mp3")));
        assetsAudioPlayer.play();

        double pickUpLocationLat =
            double.parse(dataSnapShot.value['pickup']['latitude'].toString());
        double pickUpLocationLng =
            double.parse(dataSnapShot.value['pickup']['longitude'].toString());
        String pickUpAddress = dataSnapShot.value['pickup_address'].toString();

        double dropOffLocationLat =
            double.parse(dataSnapShot.value['dropoff']['latitude'].toString());
        double dropOffLocationLng =
            double.parse(dataSnapShot.value['dropoff']['longitude'].toString());
        String dropOffAddress =
            dataSnapShot.value['dropoff_address'].toString();

        String paymentMethod = dataSnapShot.value['payment_method'].toString();

        String riderName = dataSnapShot.value["rider_name"];
        String riderPhone = dataSnapShot.value["rider_phone"];
        String riderId = dataSnapShot.value["rider_id"];

        rideDetails.rideRequestId = rideRequestId;
        rideDetails.pickupAddress = pickUpAddress;
        rideDetails.dropOffAddress = dropOffAddress;
        rideDetails.pickup = LatLng(pickUpLocationLat, pickUpLocationLng);
        rideDetails.dropOff = LatLng(dropOffLocationLat, dropOffLocationLng);
        rideDetails.paymentMethod = paymentMethod;
        rideDetails.riderId = riderId;
        rideDetails.riderName = riderName;
        rideDetails.riderPhone = riderPhone;

        print("Information :: ");
        print(rideDetails.pickupAddress);
        print(rideDetails.dropOffAddress);
      }
    });

    await usersRef
        .child(rideDetails.riderId)
        .once()
        .then((DataSnapshot dataSnapshot) {
      imageUrl = dataSnapshot.value["imageUrl"];
      userName = dataSnapshot.value["name"];
      phone = dataSnapshot.value["phone"];
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => NotificationDialog(
        rideDetails: rideDetails,
        imageUrl: imageUrl,
        userName: userName,
        phone: phone,
      ),
    );
  }
}
