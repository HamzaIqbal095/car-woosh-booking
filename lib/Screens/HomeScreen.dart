import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
// import 'package:location/location.dart';
import 'package:woooosh/Firebase/FirebaseDataBaseService.dart';
import 'package:woooosh/Firebase/FirebaseStorageService.dart';
import 'package:woooosh/Objects/CarObject.dart';
import 'package:woooosh/Objects/CompanyObject.dart';
import 'package:woooosh/Objects/MyAddressObject.dart';
import 'package:woooosh/Objects/ServiceObjject.dart';
import 'package:woooosh/Objects/ServiceTypeObject.dart';
import 'package:woooosh/Objects/UserObject.dart';
import 'package:woooosh/Screens/CongratulationsScreen.dart';
import 'package:woooosh/Screens/LoginScreen.dart';
import 'package:woooosh/Screens/MyAddressesScreen.dart';
import 'package:woooosh/Screens/MyCarsScreen.dart';
import 'package:woooosh/Screens/MyFavouritesScreen.dart';
import 'package:woooosh/Screens/OrdersHistoryScreen.dart';
import 'package:woooosh/Screens/SignupScreen.dart';
import 'package:woooosh/Screens/UserProfileScreen.dart';
import 'package:woooosh/Utils/Colors.dart';
import 'package:woooosh/Utils/CustomMarkerClass.dart';
import 'package:woooosh/Utils/Global.dart';
import 'package:woooosh/Utils/IconsUtils.dart';
import 'package:woooosh/Utils/UtilWidgets.dart';

class HomeScreen extends StatefulWidget {
  // final List<CompanyObject> companies;
  //
  // const HomeScreen({Key key, this.companies}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  UserObject currentUser;
  int selectedBottomIndex = 0;
  BitmapDescriptor cabIcon = BitmapDescriptor.defaultMarker;
  LatLng current_user;
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "";
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  ServiceObject _currentService = ServiceObject(
    selectedCars: [],
    selectedServiceTypes: [],
  );

  List<Marker> _markers = <Marker>[];
  LocationPermission permission;
  CameraPosition _kGooglePlex;
  String _mapStyle;
  GoogleMapController _controller;


  void _onMapCreated(GoogleMapController mycontroller) {
    _controller = mycontroller;
    mycontroller.setMapStyle(_mapStyle);
  }
  // Completer<GoogleMapController> _controller = Completer();

  // GoogleMapController _controller1;

  Future<void> getUser() async {
    UserObject userData = await FirebaseDataBaseService().getSingleUser();
     // print("userData"+json.encode(userData).toString());
    if (userData != null) {
      String imageName = await FirebaseStorageService()
          .getImageLink(imageName: userData.userImageName, folderName: 'Users');
      if (imageName != null) {
        userData.userImageName = imageName;
      }
      setState(() {
        currentUser = userData;
      });
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => SignupScreen(
                phoneNumber: FirebaseAuth.instance.currentUser.phoneNumber,
                email: FirebaseAuth.instance.currentUser.email),
          ),
          (route) => false);
    }
  }

  List<MyAddressObject> addresses = [];

  Future<void> getAddressesList() async {
    List<MyAddressObject> addressesData =
        await FirebaseDataBaseService().getAddressesList();

    if (addressesData != null) {
      setState(() {
        addresses = addressesData;
      });
    }
  }

  List<CarObject> cars = [];

  Future<void> getCarsList() async {
    cars.clear();
    List<CarObject> carsData = await FirebaseDataBaseService().getCarsList();
    if (carsData != null) {
      carsData.forEach((car) async {
        await FirebaseStorageService()
            .getCarImageLink(car.imageName)
            .then((value) => {
                  if (value != null)
                    {
                      setState(
                        () {
                          cars.addAll(carsData);
                        },
                      ),
                    }
                });
      });
    }
  }

  List<CompanyObject> companies = [];

  Future<void> getCompanies() async {
    await FirebaseDataBaseService().getCompaniesList().then((companiesData) => {
          if (companiesData != null)
            {
              if(mounted){
                setState(() {
                  companies = companiesData;
                  print('company data'+companiesData.toString());
                }),
              },
              MarkerGenerator(markerWidgets(), (bitmaps) {
                setState(() {
                  _markers = mapBitmapsToMarkers(bitmaps);
                });
              }).generate(context),
            }

        });
  }

  List<ServiceTypeObject> services = [];
  Future<void> getServices() async {
    await FirebaseDataBaseService().getServices().then((servicesData) => {
          if (servicesData != null)
            {
              setState(() {
                services = servicesData;
                print("services"+ services.length.toString());
              }),
            }
        });
  }

  Future<void> getFavouriteCompanies() async {
    await FirebaseDataBaseService()
        .getFavouriteCompanies()
        .then((favourites) => {
              if (favourites != null)
                {
                  setState(() {
                    favouriteCompanies = favourites;
                  }),
                }
            });
  }

  void _pickDateDialog() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      //which date will display when user open the picker
      firstDate: DateTime.now(),
      //what will be the previous supported year in picker
      lastDate: DateTime.now().add(
        const Duration(
          days: 15,
        ),
      ),
    ) //what will be the up to supported date in picker
        .then((pickedDate) {
      //then usually do the future job
      if (pickedDate == null) {
        //if user tap cancel then this function will stop
        return;
      }
      setState(() {
        //for rebuilding the ui
        _currentService.selectedDate = pickedDate;
        selectedDateTextController.text =
            DateFormat('yyyy MM-dd').format(pickedDate).toString();
      });
    });
  }

  void _pickTimeDialog() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ) //what will be the up to supported date in picker
        .then((pickedTimeData) {
      //then usually do the future job
      if (pickedTimeData == null) {
        //if user tap cancel then this function will stop
        return;
      }
      setState(() {
        //for rebuilding the ui
        _currentService.selectedTime = pickedTimeData;
        selectedTimeTextController.text =
            MaterialLocalizations.of(context).formatTimeOfDay(pickedTimeData);
      });
    });
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
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    setState(() {
      current_user = LatLng(position.latitude, position.longitude);
    });
    return position;
  }

  Timer timer;

  @override
  void initState() {
    getUser();
    getCurrentLocation().then((positions) => {
      if (positions.latitude != null)
        {
          _kGooglePlex = CameraPosition(
            target: LatLng(
              positions.latitude,
              positions.longitude,
            ),
            zoom: 17.4746,
          ),

          // _markers.add(Marker(
          //     markerId: const MarkerId('SomeId'),
          //     position: LatLng(
          //       positions.latitude,
          //       positions.longitude,
          //     ),
          //     infoWindow:
          //         const InfoWindow(title: 'The title of the marker')));
          // }),

        }
    });
    FirebaseDataBaseService().addNotificationIds();
    getAddressesList();
    getCarsList();
    getServices();
    getFavouriteCompanies();
    getCabIcon();
    rootBundle.loadString('images/map_style.txt').then((string) {
      _mapStyle = string;
    });

    timer =
        Timer.periodic(const Duration(seconds: 5), (Timer t) => getCompanies());


    super.initState();
  }


  void getCabIcon() async {
    cabIcon = await IconUtils.createMarkerImageFromAsset();
  }

  List<Marker> mapBitmapsToMarkers(List<Uint8List> bitmaps) {
    List<Marker> markersList = [];
    print("bitmap"+bitmaps.length.toString());
    bitmaps.asMap().forEach((i, bmp) {
      final company = companies[i];
      print("current"+current_user.toString());
      // if(current_user != null){
      //   getDirections(company.currentLocation,current_user);
      // }
      markersList.add(
        Marker(
          markerId: MarkerId(company.companyName),
          position: company.currentLocation,
          anchor: Offset(0.5, 0.5),
          onTap: () => {
            setState(() {
              _currentService.company = company;
            }),
            DialogUtils.showCustomDialog(
              context,
              company: company,
              service: _currentService,
              currentlocation: current_user
            ),
          },
          icon: cabIcon,
        ),
      );
    });
    print("total  marker"+companies[1].currentLocation.toString());
    return markersList;
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
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _drawerView(),
      key: _scaffoldKey,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
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
                // child: MapScreen(
                //   companies: widget.companies,
                // ),
                // child: _kGooglePlex != null
                //     ? GoogleMap(
                //         mapType: MapType.normal,
                //         myLocationButtonEnabled: false,
                //         initialCameraPosition: _kGooglePlex,
                //         onMapCreated: (GoogleMapController con) {
                //           try {
                //             _controller.complete(con);
                //           } catch (e) {
                //             print(e.toString());
                //           }
                //         },
                //         myLocationEnabled: true,
                //         // markers: Set<Marker>.of(_markers),
                //       )
                //     : const SizedBox(),
              ),
              Container(
                color: pureWhiteColor,
                height: 245,
              ),
            ],
          ),
          SafeArea(
            child: _bodyView(),
          ),
        ],
      ),
    );
  }

  Widget _bodyView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _drawerButton(),
          _bottomView(),
        ],
      ),
    );
  }

  Widget _bottomView() {
    return Column(
      children: [
        selectedBottomIndex != 0
            ? Container(
                margin: const EdgeInsets.all(20),
                height: selectedBottomIndex == 1
                    ? 320.0
                    : selectedBottomIndex == 2
                        ? 320.0
                        : selectedBottomIndex == 3
                            ? 210.0
                            : 320.0,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: pureWhiteColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 15,
                      offset: const Offset(0, 0), // changes position of shadow
                    ),
                  ],
                ),
                child: selectedBottomIndex == 1
                    ? _selectCarTabView()
                    : selectedBottomIndex == 2
                        ? _selectServiceTab()
                        : selectedBottomIndex == 3
                            ? whenTabView()
                            : choseLocationView(),
              )
            : const SizedBox(),
        Container(
          // height:
          //     (_currentService.car != null &&
          //             _currentService.serviceType != null &&
          //             _currentService.selectedDate != null &&
          //             _currentService.selectedTime != null &&
          //             _currentService.selectedAddress != null)
          //         ? 310
          //         :
          //     240,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 15,

                offset: Offset(0, -6), // changes position of shadow
              ),
            ],
            color: pureWhiteColor,
          ),
          child: Column(
            children: [
              _bottomIconsView(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(
                  thickness: 0.5,
                  color: pureBlackColor,
                ),
              ),
              GestureDetector(
                onTap: choseLocation,
                child: Container(
                  color: Colors.transparent,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: darkBlueColor,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: _currentService.selectedAddress != null
                            ? Image.asset(
                          _currentService
                              .selectedAddress.addressType ==
                              'HOME'
                              ? 'images/home_logo.png'
                              : _currentService.selectedAddress
                              .addressType ==
                              'OFFICE'
                              ? 'images/office_logo.png'
                              : 'images/other_logo.png',
                          width: 25,
                          height: 25,
                        )
                            : const Icon(
                          Icons.not_listed_location_rounded,
                          size: 25,
                          color: pureWhiteColor,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Service Location',
                            style: TextStyle(
                              color: darkBlueColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_searching,
                                color: dullFontColor,
                                size: 15,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              SizedBox(
                                width:
                                MediaQuery.of(context).size.width / 2.1,
                                child: Text(
                                  _currentService.selectedAddress != null
                                      ? _currentService.selectedAddress
                                      .pickupLocationAddress
                                      : 'Pick Location',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: dullFontColor,
                                    fontSize: 12,

                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.search,
                          color: pureBlackColor,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // (_currentService.car != null &&
              //         _currentService.serviceType != null &&
              //         _currentService.selectedDate != null &&
              //         _currentService.selectedTime != null &&
              //         _currentService.selectedAddress != null)
              //     ? Padding(
              //         padding: const EdgeInsets.all(12.0),
              //         child: BlackButtonView(
              //           label: 'Continue',
              //           context: context,
              //           loading: false,
              //           function: () => Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) => ConfirmBookingScreen(
              //                 service: _currentService,
              //               ),
              //             ),
              //           ),
              //         ),
              //       )
              //     : const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _singleAddressView({@required int index}) {
    return GestureDetector(
      onTap: () => {
        setState(() {
          _currentService.selectedAddress = addresses[index];
          selectedBottomIndex = 0;
           polylines.clear();
          // companies.forEach((element) {
          //   getDirections(_currentService.selectedAddress.pickedLocation, element.currentLocation);
          // });
        })
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _currentService.selectedAddress != null
              ? _currentService.selectedAddress.id == addresses[index].id
                  ? greenColor
                  : pureWhiteColor
              : pureWhiteColor,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Image.asset(
                  addresses[index].addressType == 'HOME'
                      ? 'images/home_logo.png'
                      : addresses[index].addressType == 'OFFICE'
                          ? 'images/office_logo.png'
                          : 'images/other_logo.png',
                  width: 30,
                  height: 30,
                ),
                const SizedBox(
                  height: 7,
                ),
                Text(
                  addresses[index].addressType,
                  style: TextStyle(
                    color: _currentService.selectedAddress != null
                        ? _currentService.selectedAddress.id ==
                                addresses[index].id
                            ? pureWhiteColor
                            : darkBlueColor
                        : darkBlueColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                )
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                addresses[index].pickupLocationAddress,
                style: const TextStyle(
                  color: pureBlackColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextEditingController selectedDateTextController = TextEditingController();
  TextEditingController selectedTimeTextController = TextEditingController();

  Widget whenTabView() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          const Text(
            'Chose Date and Time',
            style: TextStyle(
              color: darkBlueColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              top: 30,
            ),
            child: GestureDetector(
              onTap: () => _pickDateDialog(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: greenColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  _currentService.selectedDate != null
                      ? DateFormat('dd MMMM yyyy, EEEE')
                          .format(_currentService.selectedDate)
                          .toString()
                      : 'Select Date',
                  style: const TextStyle(
                    color: pureWhiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // child: TextFormField(
              //   controller: selectedDateTextController,
              //   keyboardType: TextInputType.datetime,
              //   decoration: const InputDecoration(
              //     // labelText: 'CHOOSE DATE*',
              //     labelText: 'Select Your Date*',
              //     enabled: false,
              //     contentPadding: EdgeInsets.all(0),
              //     border: UnderlineInputBorder(
              //         // borderSide: BorderSide(color: Colors.cyan),
              //         ),
              //   ),
              //   validator: (dateTime) => requiredField(dateTime, 'Your Date'),
              //   // onSaved: (customerFirstName) =>
              //   // _request.dateTime.customerFirstName = customerFirstName,
              // ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              top: 30,
            ),
            child: GestureDetector(
              onTap: () => _pickTimeDialog(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: greenColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  _currentService.selectedTime != null
                      ? MaterialLocalizations.of(context)
                          .formatTimeOfDay(_currentService.selectedTime)
                      : 'Select Time',
                  style: const TextStyle(
                    color: pureWhiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // TextFormField(
              //   controller: selectedTimeTextController,
              //   keyboardType: TextInputType.datetime,
              //   decoration: const InputDecoration(
              //     // labelText: 'CHOOSE DATE*',
              //     labelText: 'Select Your Time*',
              //     enabled: false,
              //     contentPadding: EdgeInsets.all(0),
              //     border: UnderlineInputBorder(
              //         // borderSide: BorderSide(color: Colors.cyan),
              //         ),
              //   ),
              //   validator: (dateTime) => requiredField(dateTime, 'Your Time'),
              //   // onSaved: (customerFirstName) =>
              //   // _request.dateTime.customerFirstName = customerFirstName,
              // ),
            ),
          ),
        ],
      ),
    );
  }

  Widget choseLocationView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              return _singleAddressView(index: index);
            },
          ),
        ),
        GestureDetector(
          onTap: () async => {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyAddressesScreen(),
              ),
            ).then((value) => {
                  getAddressesList(),
                }),
          },
          child: Container(
            height: 75,
            color: Colors.transparent,
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: darkBlueColor,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 26,
                        color: pureWhiteColor,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Add New Address',
                          style: TextStyle(
                            color: darkBlueColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Tap to add',
                          style: TextStyle(
                            color: dullFontColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.add,
                    color: pureBlackColor,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _selectServiceTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        itemCount: services.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0
        ),
        itemBuilder: (context, index) {
          return _singleServiceTabView(serviceData: services[index]);
        },
      ),
      // child: Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceAround,
      //   children: [
      //     Column(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         _singleServiceTabView(index: 0),
      //         _singleServiceTabView(index: 2),
      //       ],
      //     ),
      //     Column(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         _singleServiceTabView(
      //           index: 1,
      //         ),
      //         _singleServiceTabView(
      //           index: 3,
      //         ),
      //       ],
      //     ),
      //   ],
      // ),
    );
  }

  bool haveServiceTypeInList({@required ServiceTypeObject serviceTypeObject}) {
    bool done = false;

    if (_currentService.selectedServiceTypes.isNotEmpty) {
      _currentService.selectedServiceTypes.forEach((element) {
        if (element.id == serviceTypeObject.id) {
          done = true;
        }
      });
    }
    return done;
  }

  bool haveCarInList({@required CarObject carObject}) {
    bool done = false;

    if (_currentService.selectedCars.isNotEmpty) {
      _currentService.selectedCars.forEach((element) {
        if (element.id == carObject.id) {
          done = true;
        }
      });
    }
    return done;
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
              onTap: () => {
                if (!haveServiceTypeInList(serviceTypeObject: serviceData))
                  {
                    setState(() {
                      _currentService.selectedServiceTypes.add(serviceData);
                      // print(_currentService.selectedServiceTypes.length);
                      // _currentService.serviceType = serviceData;
                      // print(_currentService.serviceType.serviceTypeAmount);
                    })
                  }
                else
                  {
                    setState(() {
                      _currentService.selectedServiceTypes.remove(serviceData);
                    }),
                    // print('already in list!'),
                  }
              },
              child: Container(
                color: Colors.transparent,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: haveServiceTypeInList(
                            serviceTypeObject: serviceData)
                            ? greenColor
                            : darkBlueColor,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  snapshot.data,
                                ))),
                        width: 60,
                        height: 60,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      serviceData.serviceTypeLabel,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: haveServiceTypeInList(
                            serviceTypeObject: serviceData)
                            ? greenColor
                            : darkBlueColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Approx \$${serviceData.serviceTypeAmount}',
                      style: const TextStyle(
                        color: dullFontColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
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

  Widget _singleHomeCarView({@required int index}) {
    return GestureDetector(
      onTap: () => {
        setState(
          () {
            if (!haveCarInList(carObject: cars[index])) {
              _currentService.selectedCars.add(cars[index]);
            } else {
              print('already have!');
              _currentService.selectedCars.remove(cars[index]);
            }
            // _currentService.car = cars[index];
          },
        ),
      },
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
                  image: cars[index].carImage != null
                      ? FileImage(cars[index].carImage)
                      : NetworkImage(cars[index].imageName),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        cars[index].carModel,
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
                        cars[index].carBrand,
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
                    cars[index].carNumber,
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
              haveCarInList(carObject: cars[index])
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              size: 25,
              color: greenColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectCarTabView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, index) {
              return _singleHomeCarView(index: index);
            },
          ),
        ),
        GestureDetector(
          onTap: () async => {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyCarsScreen(),
              ),
            ).then((value) => {
                  getCarsList(),
                }),
          },
          child: Container(
            height: 75,
            color: Colors.transparent,
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: darkBlueColor,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 26,
                        color: pureWhiteColor,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Add New Car',
                          style: TextStyle(
                            color: darkBlueColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Tap to add',
                          style: TextStyle(
                            color: dullFontColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.add,
                    color: pureBlackColor,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomIconsView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _singleBottomIconView(
              iconData: FontAwesomeIcons.car, label: 'Select Car', index: 1),
          _singleBottomIconView(
              iconData: Icons.settings, label: 'Services', index: 2),
          _singleBottomIconView(
              iconData: FontAwesomeIcons.calendar, label: 'When?', index: 3),
        ],
      ),
    );
  }

  Widget _singleBottomIconView({
    @required IconData iconData,
    @required String label,
    @required int index,
  }) {
    return GestureDetector(
      onTap: () => {
        setState(() {
          if (selectedBottomIndex != index) {
            selectedBottomIndex = index;
          } else {
            selectedBottomIndex = 0;
          }
        })
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    selectedBottomIndex == index ? greenColor : darkBlueColor,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                iconData,
                size: 32,
                color: pureWhiteColor,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              label,
              style: TextStyle(
                color:
                    selectedBottomIndex == index ? greenColor : darkBlueColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerView() {
    return ClipRRect(
      // give it your desired border radius
      borderRadius: const BorderRadius.only(
        bottomRight: Radius.circular(50),
        topRight: Radius.circular(50),
      ),
      // wrap with a sizedbox for a custom width [for more flexibility]
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 80,
        child: Drawer(
          // your widgets goes here
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: Image.asset(
                          'images/drawer_close.png',
                          width: 30,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 30),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: pureWhiteColor,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 0), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: currentUser == null
                                      ? const AssetImage(
                                          'images/default_user.png')
                                      : currentUser.userImage != null
                                          ? FileImage(currentUser.userImage)
                                          : currentUser.userImageName != null
                                              ? NetworkImage(
                                                  currentUser.userImageName)
                                              : const AssetImage(
                                                  'images/default_user.png'),
                                ),
                                borderRadius: BorderRadius.circular(55),
                                color: lightGrayColor,
                              ),
                              width: 60,
                              height: 60,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentUser != null ? currentUser.userName : '',
                                style: const TextStyle(
                                  color: pureBlackColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                currentUser != null
                                    ? currentUser.userEmail
                                    : 'example@mail.com',
                                style: const TextStyle(
                                  color: dullFontColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 40, top: 20),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => openHomeScreen(context: context),
                            child: Container(
                              color: Colors.transparent,
                              child: const Text(
                                'Home',
                                style: TextStyle(
                                  color: dullFontColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: () async => {
                              Navigator.pop(context),
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrdersHistoryScreen(),
                                ),
                              ),
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: const Text(
                                'My Bookings',
                                style: TextStyle(
                                  color: dullFontColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: () async => {
                              Navigator.pop(context),
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserProfileScreen(),
                                ),
                              ),
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: const Text(
                                'My Profile',
                                style: TextStyle(
                                  color: dullFontColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: () async => {
                              Navigator.pop(context),
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyCarsScreen(),
                                ),
                              ).then(
                                (value) => {
                                  getCarsList(),
                                },
                              ),
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: const Text(
                                'My Cars',
                                style: TextStyle(
                                  color: dullFontColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: () async => {
                              Navigator.pop(context),
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyAddressesScreen(),
                                ),
                              ).then((value) => {
                                    getAddressesList(),
                                  })
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: const Text(
                                'My Addresses',
                                style: TextStyle(
                                  color: dullFontColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: () async => {
                              Navigator.pop(context),
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyFavouritesScreen(),
                                ),
                              ).then((value) => {
                                    getAddressesList(),
                                  })
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: const Text(
                                'My Favourites',
                                style: TextStyle(
                                  color: dullFontColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: () async => {
                              Navigator.pop(context),
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CongratulationsScreen(),
                                ),
                              ),
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: const Text(
                                'Contact Us',
                                style: TextStyle(
                                  color: dullFontColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => {
                    FirebaseAuth.instance.signOut(),
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                        (route) => false)
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 10),
                    child: Row(
                      children: [
                        Image.asset(
                          'images/logout.png',
                          width: 25,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        const Text(
                          'Logout',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: pureBlackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawerButton() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.only(
        left: 30,
        right: 15,
        top: 10,
        bottom: 10,
      ),
      decoration: const BoxDecoration(
        color: darkBlueColor,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.menu,
          size: 30,
          color: pureWhiteColor,
        ),
        onPressed: () => _scaffoldKey.currentState.openDrawer(),
      ),
    );
  }

  void choseLocation() {
    setState(() {
      selectedBottomIndex = selectedBottomIndex == 4 ? 0 : 4;
    });
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

}
