import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class CompanyObject {
  String id,
      email,
      password,
      companyName,
      address,
      phoneNumber,
      licenseNumber,
      socialSecurity,
      city,
      state,
      zipCode,
      udid;

  bool online;
  File image;
  LatLng currentLocation;
  String imageName;
  DateTime joiningDate;
  double amountEarned, pricePerKM, pricePerKG, rating;
  int riders, orders;

  CompanyObject({
    this.id,
    this.email,
    this.password,
    this.companyName,
    this.address,
    this.phoneNumber,
    this.licenseNumber,
    this.socialSecurity,
    this.city,
    this.state,
    this.zipCode,
    this.online,
    this.image,
    this.currentLocation,
    this.imageName,
    this.amountEarned,
    this.joiningDate,
    this.riders,
    this.orders,
    this.udid,
    this.pricePerKG,
    this.pricePerKM,
    this.rating,
  });
}
