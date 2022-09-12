import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:woooosh/Firebase/FirebaseStorageService.dart';
import 'package:woooosh/Objects/CarObject.dart';
import 'package:woooosh/Objects/ServiceObjject.dart';
import 'package:woooosh/Objects/ServiceTypeObject.dart';
import 'package:woooosh/Screens/PaymentScreen.dart';
import 'package:woooosh/Utils/Colors.dart';
import 'package:woooosh/Utils/UtilWidgets.dart';

class ConfirmBookingScreen extends StatefulWidget {
  final ServiceObject service;

  ConfirmBookingScreen({@required this.service});

  @override
  _ConfirmBookingScreenState createState() =>
      _ConfirmBookingScreenState(service: service);
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  ServiceObject service;

  _ConfirmBookingScreenState({@required this.service});

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

  void getAmount() {
    double amount = 0;
    service.selectedServiceTypes.forEach((element) {
      amount = amount + element.serviceTypeAmount;
    });

    setState(() {
      service.price = amount * service.selectedCars.length;
    });
  }

  @override
  void initState() {
    getAmount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _bodyView(),
      ),
    );
  }

  Widget _bodyView() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  appBarView(
                    label: 'Confirm Booking ',
                    function: () => Navigator.pop(context),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _companyView(),
                  _carsView(),
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
                ],
              ),
            ),
          ),
          BlackButtonView(
            label: 'Proceed to Payment',
            loading: false,
            context: context,
            function: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentScreen(service: service),
              ),
            ),
          )
        ],
      ),
    );
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
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: service.selectedCars[index].carImage !=
                                      null
                                  ? FileImage(
                                      service.selectedCars[index].carImage)
                                  : NetworkImage(
                                      service.selectedCars[index].imageName),
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

  Widget _companyView() {
    return FutureBuilder(
        future: FirebaseStorageService().getImageLink(
            imageName: service.company.imageName, folderName: 'Companies'),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data != null) {
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
}
