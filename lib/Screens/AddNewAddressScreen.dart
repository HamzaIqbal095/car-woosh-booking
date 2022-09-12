import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:woooosh/Firebase/FirebaseDataBaseService.dart';
import 'package:woooosh/Objects/MyAddressObject.dart';
import 'package:woooosh/Utils/Colors.dart';
import 'package:woooosh/Utils/CustomInputStyles.dart';
import 'package:woooosh/Utils/Global.dart';
import 'package:woooosh/Utils/UtilWidgets.dart';
import 'package:woooosh/Utils/validators.dart';

class AddNewAddressScreen extends StatefulWidget {
  @override
  _AddNewAddressScreenState createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  GlobalKey<FormState> _addAddressKey = GlobalKey<FormState>();
  TextEditingController _addressDetailsTextController = TextEditingController();
  bool switchControl = false;
  bool buttonLoading = false;
  CameraPosition _kGooglePlex;
  String _mapStyle;
  List<Marker> _markers = <Marker>[];
  GoogleMapController _controllerMap;
  // Completer<GoogleMapController> _controller = Completer();

  MyAddressObject _address = MyAddressObject();
  int selectedAddressType = -1;

  @override
  void initState() {
    getCurrentLocation().then((positions) => {
          if (positions.latitude != null)
            {
              setState(() {
                _kGooglePlex = CameraPosition(
                  target: LatLng(
                    positions.latitude,
                    positions.longitude,
                  ),
                  zoom: 19.4746,
                );
              }),
            }
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              appBarView(
                label: 'Add New Address',
                function: () => Navigator.pop(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _addAddressKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Text(
                            "Select Location",
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 320,
                            width: MediaQuery.of(context).size.width,
                            decoration:
                                const BoxDecoration(color: pureWhiteColor),
                            child: Column(
                              children: [
                                Expanded(
                                  child: _kGooglePlex != null
                                      ? Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            GoogleMap(
                                              mapType: MapType.normal,
                                              myLocationButtonEnabled: false,
                                              myLocationEnabled: true,
                                              onTap: (location) => {
                                                setState(() {
                                                  _markers.add(
                                                    Marker(
                                                      markerId: const MarkerId(
                                                          'picked'),
                                                      position: location,
                                                      infoWindow: const InfoWindow(
                                                          title:
                                                              'The title of the marker'),
                                                    ),
                                                  );
                                                  _address.pickedLocation =
                                                      location;
                                                  getLocationDetails(
                                                      locationData: location);
                                                }),
                                              },
                                              initialCameraPosition:
                                                  _kGooglePlex,
                                              onMapCreated: _onMapCreated,
                                              markers: Set<Marker>.of(_markers),
                                            ),

                                          ],
                                        )
                                      : const SizedBox(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Select Address Type",
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              _singleAddressType(
                                label: 'Home',
                                icon: 'images/home_logo.png',
                                index: 0,
                              ),
                              const SizedBox(width: 7),
                              _singleAddressType(
                                label: 'Office',
                                icon: 'images/office_logo.png',
                                index: 1,
                              ),
                              const SizedBox(width: 7),
                              _singleAddressType(
                                label: 'Other',
                                icon: 'images/other_logo.png',
                                index: 2,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Enter Address Details",
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _addressDetailsTextController,
                            validator: (pickupLocationAddress) => requiredField(
                                pickupLocationAddress, 'Address Details'),
                            onSaved: (pickupLocationAddress) => _address
                                .pickupLocationAddress = pickupLocationAddress,
                            decoration: buildCustomInput(
                              hintText: 'Enter Address Details Here',
                              labelText: null,
                            ),
                            keyboardType: TextInputType.streetAddress,
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          BlackButtonView(
                            context: context,
                            label: '+ Add New Address',
                            function: addNewAddress,
                            loading: buttonLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController mycontroller) {
    _controllerMap = mycontroller;
    mycontroller.setMapStyle(_mapStyle);
  }

  Widget _singleAddressType(
      {@required String label, @required String icon, @required int index}) {
    return GestureDetector(
      onTap: () => {
        setState(() {
          selectedAddressType = selectedAddressType == index ? -1 : index;
        })
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selectedAddressType == index ? greenColor : darkBlueColor,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              height: 22,
            ),
            const SizedBox(
              width: 7,
            ),
            Text(
              label,
              style: const TextStyle(
                color: pureWhiteColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return position;
  }

  Future<void> getLocationDetails({@required LatLng locationData}) async {
    var addresses = await Geocoder.local.findAddressesFromCoordinates(
      Coordinates(locationData.latitude, locationData.longitude),
    );

    var first = addresses.first;

    print(first.addressLine);

    setState(() {
      _address.pickupLocationAddress = first.addressLine;
      _addressDetailsTextController.text = first.addressLine;
    });
  }

  void getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    _controllerMap.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(
          position.latitude,
          position.longitude,
        ),
        zoom: 19.151926040649414)));
  }

  Future<void> addNewAddress() async {
    try {
      if (!buttonLoading) {
        if (_addAddressKey.currentState.validate()) {
          _addAddressKey.currentState.save();

          if (_address.pickedLocation != null) {
            if (selectedAddressType != -1) {
              setState(() {
                buttonLoading = true;
              });

              _address.addressType = selectedAddressType == 0
                  ? 'HOME'
                  : selectedAddressType == 1
                      ? 'OFFICE'
                      : 'OTHER';

              await FirebaseDataBaseService()
                  .addNewAddress(address: _address)
                  .then((value) => {
                        print(value.id),
                        if (value != null) Navigator.of(context).pop(value),
                      });
            } else {
              showNormalToast(msg: 'Select Address Type First!');
            }
          } else {
            showNormalToast(msg: 'Select Location First!');
          }
        }
      } else {
        showNormalToast(msg: 'Please Wait!');
      }
    } on PlatformException catch (e) {
      showNormalToast(msg: e.message);
    } catch (e) {
      showNormalToast(
          msg:
              'The connection failed because the device is not connected to the internet');
    } finally {
      setState(() {
        buttonLoading = false;
      });
    }
  }
}
