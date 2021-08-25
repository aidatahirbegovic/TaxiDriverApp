import 'package:firebase_database/firebase_database.dart';

class Drivers {
  String name;
  String phone;
  String email;
  String id;
  String carColor;
  String carModel;
  String carNumber;

  Drivers(
      {this.name,
      this.phone,
      this.email,
      this.id,
      this.carColor,
      this.carModel,
      this.carNumber});
  Drivers.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key;
    phone = dataSnapshot.value["phone"];
    email = dataSnapshot.value["email"];
    name = dataSnapshot.value["name"];
    carColor = dataSnapshot.value["car_details"]["car_color"];
    carModel = dataSnapshot.value["car_details"]["car_model"];
    carNumber = dataSnapshot.value["car_details"]["car_number"];
  }
}
