import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:woooosh/Firebase/FirebaseDataBaseService.dart';
import 'package:woooosh/Objects/CarObject.dart';
import 'package:woooosh/Objects/CompanyObject.dart';
import 'package:woooosh/Objects/MyAddressObject.dart';
import 'package:woooosh/Objects/ServiceObjject.dart';
import 'package:woooosh/Objects/ServiceTypeObject.dart';
import 'package:woooosh/Screens/OrderDetailsScreen.dart';
import 'package:woooosh/Utils/Colors.dart';
import 'package:woooosh/Utils/UtilWidgets.dart';

class OrdersHistoryScreen extends StatefulWidget {
  @override
  _OrdersHistoryScreenState createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  List<ServiceObject> services = [];

  Future<void> getServices() async {
    List<String> ordersIds =
        await FirebaseDataBaseService().getCustomerOrdersIds();
    if (ordersIds != null) {
      await getCustomerOrders(userRidesIds: ordersIds);
    }
  }

  Future<void> getCustomerOrders({@required List<String> userRidesIds}) async {
    services.clear();
    LatLng rider ;
    userRidesIds.forEach((orderKey) async {
      DatabaseReference userRideIdDbf = FirebaseDatabase.instance
          .ref()
          .child('Orders')
          .child('OrdersDetails')
          .child(orderKey);

      await userRideIdDbf.onValue.listen(
        (rideDetailsSnapshot) async{
          Map<dynamic, dynamic> rideDetails = rideDetailsSnapshot.snapshot.value;
          List<String> latlong =  rideDetails['pickedLocation'].split("and");

          List<CompanyObject> companies =
              await FirebaseDataBaseService().getCompaniesList();

          companies.forEach((element) {
              if(element.email == rideDetails['email']){
                 rider = element.currentLocation;
              }
          });

          ServiceObject service = ServiceObject(
            id: orderKey,
            company: CompanyObject(
              companyName: rideDetails['companyName'],
              imageName: rideDetails['imageName'],
              phoneNumber: rideDetails['phoneNumber'],
              email: rideDetails['email'],
              currentLocation: rider
            ),
            // car: CarObject(
            //   carBrand: rideDetails['carsList'],
            //   carModel: rideDetails['carModel'],
            //   carNumber: rideDetails['carNumber'],
            // ),
            selectedAddress: MyAddressObject(
              pickupLocationAddress: rideDetails['pickupLocationAddress'],
              addressType: rideDetails['addressType'],
              pickedLocation: LatLng(double.parse(latlong[0]),double.parse(latlong[1])),
            ),
            // serviceType: ServiceTypeObject(
            //   serviceTypeLabel: rideDetails['serviceTypeLabel'],
            //   serviceTypeAmount: double.parse(
            //     rideDetails['serviceTypeAmount'].toString(),
            //   ),
            // ),
            price: double.parse(
              rideDetails['price'].toString(),
            ),
            selectedDate: DateTime.parse(rideDetails['selectedDate']),
            selectedTime: TimeOfDay(
              hour: int.parse(
                rideDetails['selectedTime'].toString().split(':').first,
              ),
              minute: int.parse(
                rideDetails['selectedTime'].toString().split(':').last,
              ),
            ),
            paymentType: rideDetails['paymentType'],
            orderStatus: rideDetails['orderStatus'],
          );

          List<ServiceTypeObject> servicesData = [];
          List<CarObject> carsData = [];
          Map<dynamic, dynamic> valueOfCars = rideDetails['carsList'];
          Map<dynamic, dynamic> valueOfServices = rideDetails['servicesList'];

          valueOfCars.forEach((carKey, carDataValue) {
            CarObject carObject = CarObject(
              carBrand: carDataValue['carBrand'],
              carNumber: carDataValue['carNumber'],
              carModel: carDataValue['carModel'],
            );
            carsData.add(carObject);
          });

          valueOfServices.forEach((serviceKey, serviceDataValue) {
            ServiceTypeObject serviceTypeObject = ServiceTypeObject(
              iconData: serviceDataValue['iconData'],
              serviceTypeLabel: serviceDataValue['serviceTypeLabel'],
              serviceTypeAmount: double.parse(
                  serviceDataValue['serviceTypeAmount'].toString()),
            );

            servicesData.add(serviceTypeObject);
          });

          service.selectedCars = carsData;
          service.selectedServiceTypes = servicesData;

          print(
              'cars Data ${rideDetails['servicesList']}  ${service.selectedServiceTypes.length}');

          setState(() {
            services.add(service);
          });
        },
      );
    });
  }

  @override
  initState() {
    super.initState();
    getServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Orders History'),
      // ),
      body: _bodyView(),
    );
  }

  Widget _bodyView() {
    return Container(
      color: pureWhiteColor,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          children: [
            appBarView(
              label: 'My Bookings',
              function: () => Navigator.pop(context),
            ),
            Expanded(
              child: !services.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // ignore: prefer_const_literals_to_create_immutables
                        children: [
                          const Icon(
                            Icons.hourglass_empty,
                            color: darkBlueColor,
                            size: 50,
                          ),
                          const Text(
                            'Your booking is empty!',
                            style: TextStyle(
                              color: darkBlueColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        return _singleOrderView(index: index);
                      }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _singleOrderView({@required int index}) {
    return GestureDetector(
      // onTap: () => Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => OrderDetailsView(
      //       ride: services[index],
      //     ),
      //   ),
      // ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.only(bottom: 7, top: 15),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
            ),
            width: MediaQuery.of(context).size.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: darkBlueColor,
                      borderRadius: BorderRadius.circular(30)),
                  child: Image.asset(
                    services[index].selectedAddress.addressType == 'HOME'
                        ? 'images/home_logo.png'
                        : services[index].selectedAddress.addressType ==
                                'OFFICE'
                            ? 'images/office_logo.png'
                            : 'images/other_logo.png',
                    width: 20,
                    height: 20,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   '${services[index].car.carBrand} ${services[index].car.carModel}',
                      //   style: const TextStyle(
                      //     color: greenColor,
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      // Text(
                      //   services[index].car.carNumber,
                      //   style: const TextStyle(
                      //     color: dullFontColor,
                      //     fontSize: 12,
                      //     fontWeight: FontWeight.normal,
                      //   ),
                      // ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 75,
                            child: Text(
                              'Date & Time',
                              style: TextStyle(
                                color: dullFontColor,
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            '${DateFormat('dd MMMM yyyy').format(services[index].selectedDate).toString()}, ${MaterialLocalizations.of(context).formatTimeOfDay(services[index].selectedTime)}',
                            style: const TextStyle(
                              color: pureBlackColor,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 75,
                            child: Text(
                              'Order Status',
                              style: TextStyle(
                                color: dullFontColor,
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            services[index].orderStatus,
                            style: const TextStyle(
                              color: pureBlackColor,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      // const SizedBox(
                      //   height: 5,
                      // ),
                      // Row(
                      //   children: [
                      //     const SizedBox(
                      //       width: 75,
                      //       child: Text(
                      //         'Booking For',
                      //         style: TextStyle(
                      //           color: dullFontColor,
                      //           fontSize: 12,
                      //           fontWeight: FontWeight.normal,
                      //         ),
                      //       ),
                      //     ),
                      //     const SizedBox(
                      //       width: 10,
                      //     ),
                      //     Text(
                      //       services[index].serviceType.serviceTypeLabel,
                      //       style: const TextStyle(
                      //         color: pureBlackColor,
                      //         fontSize: 12,
                      //         fontWeight: FontWeight.normal,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 75,
                            child: Text(
                              'Address',
                              style: TextStyle(
                                color: dullFontColor,
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              services[index]
                                  .selectedAddress
                                  .pickupLocationAddress,
                              style: const TextStyle(
                                color: pureBlackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async => {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsScreen(
                    service: services[index],
                  ),
                ),
              ).then((value) => {
                    getServices(),
                  })
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: greenColor,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
              child: const Text(
                'view more',
                style: TextStyle(
                  color: pureWhiteColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
