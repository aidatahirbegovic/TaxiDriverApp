import 'package:driver_app/screens/newRideScreen.dart';
import 'package:driver_app/screens/registrationScreen.dart';
import 'package:driver_app/helpingMethods/assistantMethods.dart';
import 'package:driver_app/data/rideDetails.dart';
import 'package:driver_app/configMaps.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/src/public_ext.dart';

import '../constants.dart';

class NotificationDialog extends StatelessWidget {
  final RideDetails rideDetails;
  final String imageUrl;
  final String userName;
  final String phone;

  NotificationDialog(
      {this.rideDetails, this.imageUrl, this.userName, this.phone});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.transparent,
      elevation: 1.0,
      child: Container(
        margin: EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30.0,
            ),
            CircleAvatar(
              radius: 39,
              backgroundColor: Colors.yellowAccent,
              child: CircleAvatar(
                radius: 33,
                //backgroundImage: AssetImage('images/user_icon.png'),
                backgroundImage: userCurrentInfo != null
                    ? NetworkImage(imageUrl)
                    : AssetImage('images/user_icon.png'),
              ),
            ),
            SizedBox(
              height: 18.0,
            ),
            Text(
              'ride_request_from'.tr(),
              style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold"),
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(
              userName,
              style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold"),
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(
              'users_phone'.tr(),
              style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold"),
            ),
            SizedBox(
              height: 30.0,
            ),
            Text(
              phone,
              style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold"),
            ),
            SizedBox(
              height: 30.0,
            ),
            Padding(
              padding: EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "images/pickicon.png",
                        height: 16.0,
                        width: 16.0,
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Expanded(
                          child: Container(
                              child: Text(
                        rideDetails.pickupAddress,
                        style: TextStyle(fontSize: 18.0),
                      ))),
                    ],
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "images/desticon.png",
                        height: 16.0,
                        width: 16.0,
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                          child: Container(
                              child: Text(
                        rideDetails.dropOffAddress,
                        style: TextStyle(fontSize: 18.0),
                      ))),
                    ],
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Divider(
              height: 2.0,
              color: Colors.black,
              thickness: 2.0,
            ),
            SizedBox(
              height: 8.0,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      assetsAudioPlayer.stop();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'cancel'.tr(),
                      style: TextStyle(fontSize: 14.0, color: Colors.red),
                    ),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular((18.0)),
                        side: BorderSide(color: Colors.red),
                      ),
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.all(8.0),
                    ),
                  ),
                  SizedBox(
                    width: 25.0,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      assetsAudioPlayer.stop();
                      checkAvailabilityOfRide(context);
                    },
                    child: Text(
                      'accept'.tr(),
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular((18.0)),
                        side: BorderSide(color: Colors.green),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }

  void checkAvailabilityOfRide(context) {
    rideRequestRef.once().then((DataSnapshot dataSnapshot) {
      Navigator.pop(context);
      String theRideId = "";
      if (dataSnapshot.value != null) {
        theRideId = dataSnapshot.value.toString();
      } else {
        displayToastMessage('ride_not_exists'.tr(), context);
      }
      if (theRideId == rideDetails.rideRequestId) {
        rideRequestRef.set("accepted"); //driver accepted the request, busy
        AssistantMethods.disableHomeTabLiveLocationUpdate();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewRideScreen(rideDetails)));
      } else if (theRideId == "cancelled") {
        displayToastMessage('ride_cancelled'.tr(), context);
      } else if (theRideId == "timeout") {
        displayToastMessage('ride_time_out'.tr(), context);
      } else {
        displayToastMessage('ride_not_exists'.tr(), context);
      }
    });
  }
}
