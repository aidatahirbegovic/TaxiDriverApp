import 'dart:async';

import 'package:driver_app/widgets/collectFareDialog.dart';
import 'package:driver_app/widgets/progressDialog.dart';
import 'package:driver_app/helpingMethods/assistantMethods.dart';
import 'package:driver_app/helpingMethods/mapKirAssistant.dart';
import 'package:driver_app/data/rideDetails.dart';
import 'package:driver_app/configMaps.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:easy_localization/src/public_ext.dart';

import '../constants.dart';

class NewRideScreen extends StatefulWidget {
  final RideDetails rideDetails;
  NewRideScreen(this.rideDetails);

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _NewRideScreenState createState() => _NewRideScreenState();
}

class _NewRideScreenState extends State<NewRideScreen> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newRideGoogleMapController;

  Set<Marker> markerSet = Set<Marker>();
  Set<Circle> circleSet = Set<Circle>();
  Set<Polyline> polylineSet = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPaddingFromBottom = 0;
  var geoLocator = Geolocator();
  var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.bestForNavigation);
  BitmapDescriptor animatingMarkerIcon;
  Position myPosition;
  String status = "accepted"; //just accepted, moving to the users location
  String durationRide = "";
  bool isRequestingDirection = false;
  String btnTitle = 'arrived'.tr();
  Color btnColor = Colors.yellowAccent;
  Timer timer;
  int durationCounter = 0;

  @override
  void initState() {
    super.initState();

    acceptRideRequest();
  }

  void createIconMarker() {
    if (animatingMarkerIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "images/car_android.png")
          .then((value) {
        animatingMarkerIcon = value;
      });
    }
  }

  void getRideLocationUpdates() {
    LatLng oldPos = LatLng(0, 0);

    rideStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      myPosition = position;
      LatLng mPosition = LatLng(position.latitude, position.longitude);

      var rot = MapKitAssistant.getMarkerRotation(oldPos.latitude,
          oldPos.longitude, mPosition.latitude, mPosition.longitude);
      //for driver to move on lines

      Marker animatingMarker = Marker(
        markerId: MarkerId("animating"),
        position: mPosition,
        icon: animatingMarkerIcon,
        rotation: rot,
        infoWindow: InfoWindow(title: 'current_location'.tr()),
      );

      setState(() {
        CameraPosition cameraPosition =
            new CameraPosition(target: mPosition, zoom: 17);
        newRideGoogleMapController
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markerSet.removeWhere((marker) => marker.markerId.value == "animating");
        markerSet.add(animatingMarker);
      });
      oldPos = mPosition;
      updateRideDetails();

      String rideRequestId = widget.rideDetails.rideRequestId;
      Map locMap = {
        "latitude": currentPosition.latitude.toString(),
        "longitude": currentPosition.longitude.toString()
      };

      newRequestRef.child(rideRequestId).child("driver_location").set(locMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPaddingFromBottom),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: NewRideScreen._kGooglePlex,
            myLocationEnabled: true,
            markers: markerSet,
            circles: circleSet,
            polylines: polylineSet,
            onMapCreated: (GoogleMapController controller) async {
              _controllerGoogleMap.complete(controller);
              newRideGoogleMapController = controller;

              setState(() {
                mapPaddingFromBottom = 265.0;
              });

              var currentLatLng =
                  LatLng(currentPosition.latitude, currentPosition.longitude);
              var pickUpLatLng = widget.rideDetails.pickup;

              await getPlaceDirection(currentLatLng,
                  pickUpLatLng); //first driver needs to pick up user from home or office

              getRideLocationUpdates();
            },
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellowAccent,
                    blurRadius: 16.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              height: 300.0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                child: Column(
                  children: [
                    Text(
                      'duration'.tr() + durationRide,
                      style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: "Brand Bold",
                          color: Colors.redAccent),
                    ),
                    SizedBox(
                      height: 26.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.rideDetails.riderName,
                            style: TextStyle(
                                fontSize: 24.0,
                                fontFamily: "Brand Bold",
                                color: Colors.yellowAccent)),
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Icon(
                            Icons.call,
                            color: Colors.yellowAccent,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 26.0,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "images/pickicon.png",
                          height: 16.0,
                          width: 16.0,
                        ),
                        SizedBox(
                          width: 18.0,
                        ),
                        Expanded(
                          child: Text(
                            widget.rideDetails.pickupAddress,
                            style: TextStyle(
                                fontSize: 18.0, color: Colors.yellowAccent),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 26.0,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "images/desticon.png",
                          height: 16.0,
                          width: 16.0,
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Expanded(
                          child: Text(
                            widget.rideDetails.dropOffAddress,
                            style: TextStyle(
                                fontSize: 18.0, color: Colors.yellowAccent),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (status == "accepted") {
                            //driver must move to pickup location of user
                            status = "arrived";
                            String rideRequestId =
                                widget.rideDetails.rideRequestId;
                            newRequestRef
                                .child(rideRequestId)
                                .child("status")
                                .set(status);

                            setState(() {
                              btnTitle = 'start_trip'.tr();
                              btnColor = Colors.yellowAccent;
                            });

                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) =>
                                    ProgressDialog(
                                      message: 'please_wait'.tr(),
                                    ));

                            await getPlaceDirection(widget.rideDetails.pickup,
                                widget.rideDetails.dropOff);

                            Navigator.pop(context);
                          } else if (status == "arrived") {
                            //driver must move to pickup location of user
                            status = "onride";
                            String rideRequestId =
                                widget.rideDetails.rideRequestId;
                            newRequestRef
                                .child(rideRequestId)
                                .child("status")
                                .set(status);

                            setState(() {
                              btnTitle = 'end_trip'.tr();
                              btnColor = Colors.redAccent;
                            });
                            initTimer();
                          } else if (status == "onride") {
                            endTheTrip();
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: btnColor,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(17.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                btnTitle,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              Icon(
                                Icons.directions_car,
                                color: Colors.black,
                                size: 26.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> getPlaceDirection(
      LatLng pickUpLatLng, LatLng dropOffLatLng) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: 'please_wait'.tr(),
            ));

    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);

    Navigator.pop(context);

    print("This is Encoded Points ::");
    print(details.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    polylineCoordinates.clear();

    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        polylineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polylineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newRideGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: dropOffLatLng,
      markerId: MarkerId("dropOffId"),
    );

    setState(() {
      markerSet.add(pickUpLocMarker);
      markerSet.add(dropOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.blueAccent,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
      circleId: CircleId("pickUpId"),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.deepPurple,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
      circleId: CircleId("dropOffId"),
    );

    setState(() {
      circleSet.add(pickUpLocCircle);
      circleSet.add(dropOffLocCircle);
    });
  }

  void acceptRideRequest() {
    String rideRequestId = widget.rideDetails.rideRequestId;
    newRequestRef.child(rideRequestId).child("status").set("accepted");
    newRequestRef
        .child(rideRequestId)
        .child("driver_name")
        .set(driversInformation.name);
    newRequestRef
        .child(rideRequestId)
        .child("driver_phone")
        .set(driversInformation.phone);
    newRequestRef
        .child(rideRequestId)
        .child("driver_id")
        .set(driversInformation.id);
    newRequestRef.child(rideRequestId).child("car_details").set(
        '${driversInformation.carColor} - ${driversInformation.carModel} - ${driversInformation.carNumber}');

    Map locMap = {
      "latitude": currentPosition.latitude.toString(),
      "longitude": currentPosition.longitude.toString()
    };

    newRequestRef.child(rideRequestId).child("driver_location").set(locMap);

    driversRef
        .child(currentFirebaseUser.uid)
        .child("history")
        .child(rideRequestId)
        .set(true);
  }

  void updateRideDetails() async {
    if (myPosition == null) {
      return;
    }
    if (isRequestingDirection == false) {
      isRequestingDirection = true;
      var posLatLng = LatLng(myPosition.latitude, myPosition.longitude);
      LatLng destinationLatLng;

      if (status == "accepted") {
        //driver is going to pickup user from his address, home
        destinationLatLng = widget.rideDetails.pickup;
      } else {
        //driver has picked up user from location, moving to destination
        destinationLatLng = widget.rideDetails.dropOff;
      }

      var directionDetails = await AssistantMethods.obtainPlaceDirectionDetails(
          posLatLng, destinationLatLng);
      if (directionDetails != null) {
        setState(() {
          durationRide = directionDetails.durationText;
        });
      }
      isRequestingDirection = false;
    }
  }

  void initTimer() {
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      durationCounter = durationCounter + 1;
    });
  }

  void endTheTrip() async {
    timer.cancel();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ProgressDialog(
              message: 'please_wait'.tr(),
            ));

    var currentLatLng = LatLng(myPosition.latitude, myPosition.longitude);

    var directionalDetails = await AssistantMethods.obtainPlaceDirectionDetails(
        widget.rideDetails.pickup, currentLatLng);

    Navigator.pop(context);

    int fareAmount = AssistantMethods.calculateFares(directionalDetails);

    String rideRequestId = widget.rideDetails.rideRequestId;
    newRequestRef
        .child(rideRequestId)
        .child("fares")
        .set(fareAmount.toString());
    newRequestRef.child(rideRequestId).child("status").set("ended");

    rideStreamSubscription.cancel(); //cancel live location update
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CollectFareDialog(
              paymentMethod: widget.rideDetails.paymentMethod,
              fareAmount: fareAmount,
            ));
    saveEarnings(fareAmount);
  }

  void saveEarnings(int fareAmount) {
    driversRef
        .child(currentFirebaseUser.uid)
        .child("earnings")
        .once()
        .then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        double oldEarnings = double.parse(dataSnapshot.value.toString());
        double totalEarnings = fareAmount + oldEarnings;

        driversRef
            .child(currentFirebaseUser.uid)
            .child("earnings")
            .set(totalEarnings.toStringAsFixed(2));
      } else {
        //for new drivers that dont have earnings
        double totalEarnings = fareAmount.toDouble();
        driversRef
            .child(currentFirebaseUser.uid)
            .child("earnings")
            .set(totalEarnings.toStringAsFixed(2));
      }
    });
  }
}
