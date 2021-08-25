import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:driver_app/data/allUsers.dart';
import 'package:geolocator/geolocator.dart';

import 'data/drivers.dart';

String mapKey = "AIzaSyAX0e4XXlkniZfsxvSzCJCividSUlxRw_U";

User firebaseUser;

Users userCurrentInfo;

User currentFirebaseUser;

StreamSubscription<Position> homeTabPageStreamSubscription;
StreamSubscription<Position> rideStreamSubscription;

final assetsAudioPlayer = AssetsAudioPlayer();

Position currentPosition;

Drivers driversInformation;

String title = "";

double starCounter = 0.0;
