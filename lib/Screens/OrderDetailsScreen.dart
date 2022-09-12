import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:woooosh/Firebase/FirebaseDataBaseService.dart';
import 'package:woooosh/Firebase/FirebaseStorageService.dart';
import 'package:woooosh/Objects/CarObject.dart';
import 'package:woooosh/Objects/CompanyObject.dart';
import 'package:woooosh/Objects/ServiceObjject.dart';
import 'package:woooosh/Objects/ServiceTypeObject.dart';
import 'package:woooosh/Utils/Colors.dart';
import 'package:woooosh/Utils/CustomMarkerClass.dart';
import 'package:woooosh/Utils/Global.dart';
import 'package:woooosh/Utils/IconsUtils.dart';
import 'package:woooosh/Utils/MapUtils.dart';
import 'package:woooosh/Utils/UtilWidgets.dart';

class OrderDetailsScreen extends StatefulWidget {
  final ServiceObject service;

  OrderDetailsScreen({@required this.service});

  @override
  _OrderDetailsScreenState createState() =>
      _OrderDetailsScreenState(service: service);
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  ServiceObject service;

  _OrderDetailsScreenState({@required this.service});
  CameraPosition _kGooglePlex;
  bool buttonLoading = false;
  LatLng current_user;
  PolylinePoints polylinePoints = PolylinePoints();
  BitmapDescriptor cabIcon = BitmapDescriptor.defaultMarker;
  String googleAPiKey = "";
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  List<Marker> _markers = <Marker>[];
  LocationPermission permission;
  String _mapStyle;
  List<CompanyObject> companies = [];
  GoogleMapController _controller;
  bool haveServiceTypeInList({@required ServiceTypeObject serviceTypeObject}) {
    bool done = false;

    if (service.selectedServiceTypes.isNotEmpty) {
      service.selectedServiceTypes.forEach((element) {
        if (element.id == serviceTypeObject.id) {
          done = true;
        }
      });
    }
    return done;
  }

  bool haveCarInList({@required CarObject carObject}) {
    bool done = false;
    if (service.selectedCars.isNotEmpty) {
      service.selectedCars.forEach((element) {
        if (element.id == carObject.id) {
          done = true;
        }
      });
    }
    return done;
  }
  List<Marker> mapBitmapsToMarkers(List<Uint8List> bitmaps) {
    List<Marker> markersList = [];

    print("bitmap"+bitmaps.length.toString());
    bitmaps.asMap().forEach((i, bmp) async{
      final company = companies[i];
      final double bearing = await MapUtils.getRotation(company.currentLocation, service.selectedAddress.pickedLocation);
      print("current"+current_user.toString());
      // if(current_user != null){
      //   getDirections(company.currentLocation,current_user);
      // }
      markersList.add(
        Marker(
          markerId: MarkerId(company.companyName),
          position: company.currentLocation,
          anchor: Offset(0.5, 0.5),
          icon: cabIcon,
          flat: true,
          draggable: false,
          rotation: bearing
        ),
      );
    });
    markersList.add(
      Marker(
        markerId: MarkerId(service.selectedAddress.pickupLocationAddress),
        position: service.selectedAddress.pickedLocation,
        anchor: Offset(0.5, 0.5),
        icon: BitmapDescriptor.defaultMarker,
      ),
    );
    return markersList;
  }

  void _onMapCreated(GoogleMapController mycontroller) {
    _controller = mycontroller;
    mycontroller.setMapStyle(_mapStyle);
  }

  List<Widget> markerWidgets() {
    return companies.map((c) => _getMarkerWidget(c)).toList();
  }

// Example of marker widget
  Widget _getMarkerWidget(CompanyObject company) {
    return Container(
        height: 140,
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1.5),
        child: Column(
          children: [
            const Icon(
              FontAwesomeIcons.car,
              color: darkBlueColor,
              size: 50,
            ),
            Text(
              company.companyName,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ));
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation().then((positions) => {
      if (positions.latitude != null)
        {
          _kGooglePlex = CameraPosition(
            target: LatLng(
              positions.latitude,
              positions.longitude,
            ),
            zoom: 12.4746,
          ),
        }
    });
    rootBundle.loadString('images/map_style.txt').then((string) {
      _mapStyle = string;
    });
   companies.add(service.company);
    MarkerGenerator(markerWidgets(), (bitmaps) {
      setState(() {
        _markers = mapBitmapsToMarkers(bitmaps);
      });
    }).generate(context);
    getCabIcon();
    getDirections(service.selectedAddress.pickedLocation != null ? service.selectedAddress.pickedLocation : current_user, service.company.currentLocation);
  }

  void getCabIcon() async {
    cabIcon = await IconUtils.createMarkerImageFromAsset();
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

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    setState(() {
      print("das current"+position.latitude.toString());
      current_user = LatLng(position.latitude, position.longitude);
    });
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _bodyView(),
      ),
    );
  }

  getDirections(LatLng slat,LatLng dlat) async {
    List<LatLng> polylineCoordinates = [];
    if(polylines.isEmpty){
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(slat.latitude, slat.longitude),
        PointLatLng(dlat.latitude, dlat.longitude),
        travelMode: TravelMode.driving,
      );

      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      } else {
        print(result.errorMessage);
      }
      addPolyLine(polylineCoordinates);
      print("locations"+json.encode(polylineCoordinates).toString());
    }
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: darkBlueColor,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  Widget _bodyView() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          service.orderStatus != 'DELIVERED'  && service.orderStatus != 'COMPLETED' ? Expanded(
            flex: 2,
            child: _kGooglePlex != null
                ? GoogleMap(
              onMapCreated: _onMapCreated,
              polylines: Set<Polyline>.of(polylines.values),
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              initialCameraPosition: _kGooglePlex,
              // initialCameraPosition: const CameraPosition(
              //     target: LatLng(32.1766899, 74.2061979), zoom: 16),
              markers: _markers.toSet(),
            )
                : const SizedBox(),
          ):Container(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  appBarView(
                    label: 'Booking Details',
                    function: () => Navigator.pop(context),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _companyView(),
                  _carsView(),
                  // _singleTabView(
                  //   title: 'Car Selected',
                  //   value: '${service.car.carBrand} ${service.car.carModel}',
                  //   value1: service.car.carNumber,
                  // ),
                  _singleTabView(
                    title: 'Date & Time',
                    value: DateFormat('dd MMMM yyyy, EEEE')
                        .format(service.selectedDate)
                        .toString(),
                    value1: MaterialLocalizations.of(context)
                        .formatTimeOfDay(service.selectedTime),
                  ),
                  _servicesView(),

                  // _singleTabView(
                  //   title: 'Service Selected',
                  //   value: service.serviceType.serviceTypeLabel,
                  //   value1: 'Approx \$${service.serviceType.serviceTypeAmount}',
                  // ),
                  _singleTabView(
                    title: 'Location',
                    value: service.selectedAddress.addressType,
                    value1:
                        'Approx \$${service.selectedAddress.pickupLocationAddress}',
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Payable Amount:',
                          style: TextStyle(
                            color: darkBlueColor,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '\$${service.price}',
                          style: const TextStyle(
                            color: darkBlueColor,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Order Status:',
                          style: TextStyle(
                            color: darkBlueColor,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          service.orderStatus,
                          style: const TextStyle(
                            color: darkBlueColor,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (service.orderStatus == 'DELIVERED')
            BlackButtonView(
              label: 'Make Order Complete',
              loading: buttonLoading,
              context: context,
              function: makeOrderComplete,
            ),
          // BlackButtonView(
          //   label: 'Review',
          //   loading: false,
          //   context: context,
          //   function: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => PaymentScreen(service: service),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _companyView() {
    return FutureBuilder(
        future: FirebaseStorageService().getImageLink(
            imageName: service.company.imageName, folderName: 'Companies'),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data != null) {
            // getDirections(,service.company.currentLocation);
            print("dsadsad"+ service.company.currentLocation.toString());
            return Container(
              padding: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: dullBlueColor,
              ),
              child: Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      image: DecorationImage(
                        image: NetworkImage(snapshot.data),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.company.companyName,
                        style: const TextStyle(
                          color: darkBlueColor,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        service.company.email,
                        style: const TextStyle(
                          color: darkBlueColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        service.company.phoneNumber,
                        style: const TextStyle(
                          color: pureWhiteColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }

  Widget _servicesView() {
    return Container(
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: dullBlueColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Selected',
            style: TextStyle(
              color: darkBlueColor,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            height: 80 * service.selectedServiceTypes.length.toDouble(),
            child: ListView.builder(
              itemCount: service.selectedServiceTypes.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return GestureDetector(
                  child: _singleServiceTabView(
                      serviceData: service.selectedServiceTypes[index]),
                );
              },
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(20.0),
          //   child: Wrap(
          //     alignment: WrapAlignment.center,
          //     direction: Axis.horizontal,
          //     runSpacing: MediaQuery.of(context).size.width / 8,
          //     spacing: MediaQuery.of(context).size.width / 5,
          //     children: service.selectedServiceTypes
          //         .map((i) =>
          //             _singleServiceTabView(serviceData: i))
          //         .toList(),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _carsView() {
    return Container(
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: dullBlueColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Car Selected',
            style: TextStyle(
              color: darkBlueColor,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            height: 80 * service.selectedCars.length.toDouble(),
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: service.selectedCars.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  // onTap: () => {
                  //   setState(
                  //     () {
                  //       if (!haveCarInList(
                  //           carObject:
                  //               service.selectedCars[index])) {
                  //         service.selectedCars
                  //             .add(service.selectedCars[index]);
                  //       } else {
                  //         print('already have!');
                  //         service.selectedCars.remove(
                  //             service.selectedCars[index]);
                  //       }
                  //       // _currentService.car = cars[index];
                  //     },
                  //   ),
                  // },
                  child: Container(
                    height: 75,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      color: grayColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Container(
                        //   height: 50,
                        //   width: 50,
                        //   decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(35),
                        //     image: DecorationImage(
                        //       fit: BoxFit.fill,
                        //       image: service.selectedCars[index].carImage !=
                        //               null
                        //           ? FileImage(
                        //               service.selectedCars[index].carImage)
                        //           : NetworkImage(
                        //               service.selectedCars[index].imageName),
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(
                        //   width: 10,
                        // ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    service.selectedCars[index].carModel,
                                    style: const TextStyle(
                                      color: pureBlackColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    service.selectedCars[index].carBrand,
                                    style: const TextStyle(
                                      color: dullFontColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                service.selectedCars[index].carNumber,
                                style: const TextStyle(
                                  color: dullFontColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Icon(
                          haveCarInList(carObject: service.selectedCars[index])
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 25,
                          color: greenColor,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _singleServiceTabView({
    @required ServiceTypeObject serviceData,
  }) {
    return FutureBuilder(
        future: FirebaseStorageService().getImageLink(
            imageName: serviceData.iconData, folderName: 'Services'),
        builder: (BuildContext contect, AsyncSnapshot snapshot) {
          if (snapshot.data != null) {
            return GestureDetector(
              child: Container(
                height: 75,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: grayColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(snapshot.data),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceData.serviceTypeLabel,
                            style: const TextStyle(
                              color: pureBlackColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            'Approx ${serviceData.serviceTypeAmount}',
                            style: const TextStyle(
                              color: dullFontColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Icon(
                      haveServiceTypeInList(serviceTypeObject: serviceData)
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 25,
                      color: greenColor,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }

  Widget _singleTabView(
      {@required String title,
      @required String value,
      @required String value1}) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: dullBlueColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: darkBlueColor,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            value,
            style: const TextStyle(
              color: pureWhiteColor,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            value1,
            style: const TextStyle(
              color: pureWhiteColor,
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
  void _showRatingDialog() {
    // actual store listing review & rating

    final _dialog = RatingDialog(
      initialRating: 1.0,
      starSize: 20,
      // your app's name?
      title: Text(
        'Rating Dialog',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      // encourage your user to leave a high rating?
      message: Text(
        'Please give your feedback',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15),
      ),
      // your app's logo?
      image: Image.asset('images/wooosh_logo.png',height: 70,),
      submitButtonText: 'Submit',
      commentHint: 'Leave your comment',
      onCancelled: () => print('cancelled'),
      onSubmitted: (response) {
        print('rating: ${response.rating}, comment: ${response.comment}');

        // TODO: add your own logic
        if (response.rating > 0.0) {
          FirebaseDataBaseService().AddReview(stars:response.rating.toString(),comment:response.comment.toString());
          // send their comments to your email or anywhere you wish
          // ask the user to contact you instead of leaving a bad review
        }
      },
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: true, // set to false if you want to force a rating
      builder: (context) => _dialog,
    );
  }

  Future<void> makeOrderComplete() async {
    try {
      if (!buttonLoading) {
        setState(() {
          buttonLoading = true;
        });
        _showRatingDialog();
        await FirebaseDataBaseService()
            .makeOrderComplete(service: service)
            .then(
              (done) => {
                if (done != null)
                  {

                    showNormalToast(msg: 'Order Completed!'),
                    setState(() {
                      buttonLoading = false;
                      service.orderStatus = 'COMPLETED';
                    }),

                  },
              },
            );
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
