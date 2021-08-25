import 'package:driver_app/screens/loginScreen.dart';
import 'package:driver_app/configMaps.dart';
import 'package:driver_app/screens/updateProfileInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:easy_localization/src/public_ext.dart';

import '../constants.dart';

class ProfileTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.yellowAccent,
                  child: CircleAvatar(
                    radius: 39,
                    backgroundImage: userCurrentInfo != null
                        ? NetworkImage(userCurrentInfo.imageUrl)
                        : AssetImage('images/user_icon.png'),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      driversInformation.name,
                      style: TextStyle(
                        fontSize: 65.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Signatra',
                      ),
                    ),
                    Text(
                      title + 'driver'.tr(),
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.blueGrey[200],
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Brand-Regular'),
                    ),
                    SizedBox(
                      height: 20,
                      width: 200,
                      child: Divider(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 40.0,
            ),
            InfoCard(
              text: driversInformation.phone,
              icon: Icons.phone,
              onPressed: () async {
                print("this is phone.");
              },
            ),
            InfoCard(
              text: driversInformation.email,
              icon: Icons.email,
              onPressed: () async {
                print("this is email.");
              },
            ),
            InfoCard(
              text: driversInformation.carColor +
                  " " +
                  driversInformation.carModel +
                  " " +
                  driversInformation.carNumber,
              icon: Icons.car_repair,
              onPressed: () async {
                print("this is car info.");
              },
            ),
            GestureDetector(
              onTap: () {
                Geofire.removeLocation(currentFirebaseUser.uid);
                if (rideRequestRef != null) {
                  rideRequestRef.onDisconnect();
                  rideRequestRef.remove();
                  rideRequestRef = null;
                }

                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginScreen.idScreen, (route) => false);
              },
              child: Card(
                color: Colors.yellowAccent,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 110.0),
                child: ListTile(
                  trailing: Icon(
                    Icons.follow_the_signs_outlined,
                    color: Colors.black,
                  ),
                  title: Text(
                    'sign_out'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontFamily: 'Brand Bold',
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UpdateInfo())),
              child: Card(
                color: Colors.yellowAccent,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 110.0),
                child: ListTile(
                  trailing: Icon(
                    Icons.update,
                    color: Colors.black,
                  ),
                  title: Text(
                    'update_info'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontFamily: 'Brand Bold',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function onPressed;

  InfoCard({
    this.text,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.black87,
          ),
          title: Text(
            text,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16.0,
              fontFamily: 'Brand Bold',
            ),
          ),
        ),
      ),
    );
  }
}
