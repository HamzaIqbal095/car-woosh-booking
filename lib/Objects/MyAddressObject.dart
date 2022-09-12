import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyAddressObject {
  String id, pickupLocationAddress, addressType;
  LatLng pickedLocation;

  MyAddressObject({
    this.id,
    this.pickupLocationAddress,
    this.addressType,
    this.pickedLocation,
  });
}
