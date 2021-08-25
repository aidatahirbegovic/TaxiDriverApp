import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideDetails
{
  String pickupAddress;
  String dropOffAddress;
  LatLng pickup;
  LatLng dropOff;
  String rideRequestId;
  String paymentMethod;
  String riderId;
  String riderName;
  String riderPhone;

  RideDetails({this.pickupAddress, this.dropOffAddress, this.pickup, this.dropOff, this.rideRequestId, this.paymentMethod,this.riderName, this.riderPhone});
}