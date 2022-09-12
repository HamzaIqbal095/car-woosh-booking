import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:woooosh/.enve.dart';
import 'package:woooosh/Firebase/FirebaseDataBaseService.dart';
import 'package:woooosh/Screens/HomeScreen.dart';
import 'package:woooosh/Utils/Colors.dart';
import 'package:woooosh/Utils/UtilWidgets.dart';

Image appLogo = Image.asset(
  'images/wooosh_logo.png',
  width: 250,
);

List<String> favouriteCompanies = [];

// List<ServiceTypeObject> servicesTypes = [
//   ServiceTypeObject(
//     id: 0,
//     iconData: FontAwesomeIcons.car,
//     serviceTypeLabel: 'Bodywash',
//     serviceTypeAmount: 50,
//   ),
//   ServiceTypeObject(
//     id: 1,
//     iconData: FontAwesomeIcons.carSide,
//     serviceTypeLabel: 'Interior Room',
//     serviceTypeAmount: 40,
//   ),
//   ServiceTypeObject(
//     id: 2,
//     iconData: Icons.car_repair_sharp,
//     serviceTypeLabel: 'Engine detailing',
//     serviceTypeAmount: 80,
//   ),
//   ServiceTypeObject(
//     id: 3,
//     iconData: FontAwesomeIcons.solidSun,
//     serviceTypeLabel: 'Car Polish',
//     serviceTypeAmount: 30,
//   ),
// ];

enum PaymentType { CARD, CASH_ON_DELIVERY }

void showNormalToast({@required String msg}) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
//          timeInSecForIos: 1,
      backgroundColor: const Color(0xff666666),
      textColor: pureWhiteColor,
      fontSize: 16.0);
}

Future<void> openHomeScreen({BuildContext context}) async {
  await FirebaseDataBaseService().getCompaniesList().then((companiesData) => {
        print(companiesData.length),
        if (companiesData != null)
          {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
                (route) => false),
          }
      });
}

double calculateDistance({lat1, lon1, lat2, lon2}) {
  print('m called');
  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  print((12742 * asin(sqrt(a))).toString());
  double distnace = 12742 * asin(sqrt(a));
  print("distance"+distnace.toString());
  return distnace;
}
 Future<String> getDistanceMatrix({lat1, lon1, lat2, lon2}) async {
  try {
    var response = await Dio().get(
        'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${lat2},${lon2}&origins=${lat1},${lon2}&key=$googleAPIKey');
    print("cahsbkjsc"+response.data.toString());
    print("cahsbkjscdas"+response.data['rows'][0]['elements'][0]['duration']['text'].toString());
    time =response.data['rows'][0]['elements'][0]['duration']['text'].toString();
    print("time"+response.data['rows'][0]['elements'][0]['duration']['text'].toString());
    return time;
  } catch (e) {
    print(e);
  }
}
