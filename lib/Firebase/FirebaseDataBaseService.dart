import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:woooosh/Objects/CarObject.dart';
import 'package:woooosh/Objects/CompanyObject.dart';
import 'package:woooosh/Objects/MyAddressObject.dart';
import 'package:woooosh/Objects/ServiceObjject.dart';
import 'package:woooosh/Objects/ServiceTypeObject.dart';
import 'package:woooosh/Objects/UserObject.dart';
import 'package:woooosh/main.dart';

class FirebaseDataBaseService {
  final FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;

  Future<bool> addNewUser({@required UserObject user}) async {
    DatabaseReference dbf = firebaseDatabase.ref();
    final User currentUser = FirebaseAuth.instance.currentUser;
    String userUID = currentUser.uid;

    // String imageName = userObject.userImage != null
    //     ? '$userUID.${userObject.userImage.path.split('/').last.split('.').last}'
    //     : 'default';
    try {
      Map<String, dynamic> userData = {
        'userUID': userUID,
        'userName': user.userName,
        'userImage': 'default.png',
        'userEmail': user.userEmail.isNotEmpty ? user.userEmail : 'not avail',
        'userPhoneNumber': user.userPhoneNumber,
      };

      await dbf.child('Users').child(userUID).set(userData);

      return true;
    } catch (e) {
      print("Here");
      print(e);
      return false;
    }
  }

  Future<UserObject> getSingleUser() async {
    try {
      UserObject user;

      DatabaseReference dbf = firebaseDatabase
          .ref()
          .child('Users')
          .child(FirebaseAuth.instance.currentUser.uid);
      // .child(FirebaseAuth.instance.currentUser.uid);

      await dbf.once().then((snapshot) {
        Map<dynamic, dynamic> values = snapshot.snapshot.value;

        user = UserObject(
          userUID: FirebaseAuth.instance.currentUser.uid,
          userName: values['userName'],
          userImageName: values['userImage'],
          userPhoneNumber: values['userPhoneNumber'],
          userId: values['userUID'],
          userEmail: values['userEmail'],
        );
      });
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool> updateUser({@required UserObject user}) async {
    DatabaseReference dbf = firebaseDatabase.ref();
    final User currentUser = FirebaseAuth.instance.currentUser;
    String userUID = currentUser.uid;

    try {
      Map<String, dynamic> userData = {
        'userName': user.userName,
        'userEmail': user.userEmail.isNotEmpty ? user.userEmail : 'not avail',
      };

      await dbf.child('Users').child(userUID).update(userData);

      return true;
    } catch (e) {
      print("Here");
      print(e);
      return false;
    }
  }

  Future<bool> editUserProfilePicture(UserObject userObject) async {
    DatabaseReference dbf = firebaseDatabase.ref();

    String imageName = userObject.userImage != null
        ? '${userObject.userUID}.${userObject.userImage.path.split('/').last.split('.').last}'
        : userObject.userImageName ?? 'default';
    try {
      Map<String, dynamic> userData = {
        'userImage': imageName,
      };

      final User currentUser = FirebaseAuth.instance.currentUser;

      String userUID = currentUser.uid;
      await dbf.child('Users').child(userUID).update(userData);

      return true;
    } catch (e) {
//      print("Here");
      print(e);
      return false;
    }
  }

  Future<bool> getPhoneNumberConfirm(String phoneNumber) async {
    bool find = false;
    DatabaseReference dbf = firebaseDatabase.ref().child('Users');

    await dbf.once().then((snapshot) {
      Map<dynamic, dynamic> value = snapshot.snapshot.value;
      if (value != null) {
        value.forEach((key, values) {
          if (values['userPhoneNumber'] == phoneNumber) {
            find = true;
          }
        });
      }
    });

    return find;
  }

  Future<CarObject> addNewCar({@required CarObject car}) async {
    DatabaseReference dbf = firebaseDatabase.ref();
    final User currentUser = FirebaseAuth.instance.currentUser;
    String userUID = currentUser.uid;

    String imageName = car.carImage != null
        ? car.carImage.path.split('/').last
        : 'default.png';

    String carId = dbf.child('Cars').child(userUID).push().key;
    try {
      Map<String, dynamic> carData = {
        'carBrand': car.carBrand,
        'carModel': car.carModel,
        'imageName': imageName,
        'carType': car.carType,
        'carNumber': car.carNumber,
      };

      await dbf
          .child('Cars')
          .child(userUID)
          .child(carId)
          .set(carData)
          .then((value) => {
                car.id = carId,
              });

      return car;
    } catch (e) {
      print("Here");
      print(e);
      return null;
    }
  }

  Future<List<CarObject>> getCarsList() async {
    List<CarObject> carsData = [];
    DatabaseReference dbf = firebaseDatabase
        .ref()
        .child('Cars')
        .child(FirebaseAuth.instance.currentUser.uid);

    await dbf.once().then((snapshot) {
      print("cars data"+snapshot.snapshot.value.toString());
      Map<dynamic, dynamic> value = snapshot.snapshot.value;
      if (value != null) {
        value.forEach((key, values) {
          CarObject car = CarObject(
            id: key,
            imageName: values['imageName'],
            carModel: values['carModel'],
            carBrand: values['carBrand'],
            carType: values['carType'],
            carNumber: values['carNumber'],
          );
          carsData.add(car);
//
        });
      }
    });
    print("cars data 1"+ carsData.toString());
    return carsData;
    // ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<MyAddressObject> addNewAddress(
      {@required MyAddressObject address}) async {
    DatabaseReference dbf = firebaseDatabase.ref();
    final User currentUser = FirebaseAuth.instance.currentUser;
    String userUID = currentUser.uid;

    // String imageName = address.carImage != null
    //     ? address.carImage.path.split('/').last
    //     : 'default.png';

    String addressId = dbf.child('Addresses').child(userUID).push().key;
    try {
      Map<String, dynamic> carData = {
        'addressType': address.addressType,
        'pickedLocation':
            '${address.pickedLocation.latitude} and ${address.pickedLocation.longitude}',
        'pickupLocationAddress': address.pickupLocationAddress,
      };

      await dbf
          .child('Addresses')
          .child(userUID)
          .child(addressId)
          .set(carData)
          .then((value) => {
                address.id = addressId,
              });

      return address;
    } catch (e) {
      print("Here");
      print(e);
      return null;
    }
  }

  Future<MyAddressObject> AddReview({String stars,String comment}) async {
    DatabaseReference dbf = firebaseDatabase.ref();
    final User currentUser = FirebaseAuth.instance.currentUser;
    String userUID = currentUser.uid;

    // String imageName = address.carImage != null
    //     ? address.carImage.path.split('/').last
    //     : 'default.png';

    // String addressId = dbf.child('reviews').child(userUID).push().key;
    try {
      Map<String, dynamic> reviewdata = {
        'reviews': stars,
        'comment': comment,
      };

      await dbf
          .child('reviews')
          .child(userUID)
          .set(reviewdata)
          .then((value) => {

      });
    } catch (e) {
      print("Here");
      print(e);
      return null;
    }
  }

  Future<MyAddressObject> addNotificationIds() async {
    print("idss sid 1");
    DatabaseReference dbf = firebaseDatabase.ref();
    print("idss sid 2");
    final User currentUser = FirebaseAuth.instance.currentUser;
    String userUID = currentUser.uid;
    final status = await OneSignal.shared.getDeviceState();
    final playerId = status.userId;
     print("idss sid"+playerId);
    // String imageName = address.carImage != null
    //     ? address.carImage.path.split('/').last
    //     : 'default.png';

    // String addressId = dbf.child('reviews').child(userUID).push().key;
    try {
      Map<String, dynamic> notification_data = {
        'one_id': playerId,
      };

      await dbf
          .child('notification_ids')
          .child(userUID)
          .set(notification_data)
          .then((value) => {

      });
    } catch (e) {
      print("Here");
      print(e);
      return null;
    }
  }

  Future<List<MyAddressObject>> getAddressesList() async {
    List<MyAddressObject> addressesData = [];
    DatabaseReference dbf = firebaseDatabase
        .ref()
        .child('Addresses')
        .child(FirebaseAuth.instance.currentUser.uid);

    await dbf.once().then((snapshot) {
      print(snapshot.snapshot.value);
      Map<dynamic, dynamic> value = snapshot.snapshot.value;
      if (value != null) {
        value.forEach((key, values) {
          MyAddressObject address = MyAddressObject(
            id: key,
            addressType: values['addressType'],
            pickupLocationAddress: values['pickupLocationAddress'],
            pickedLocation: LatLng(
              double.parse(
                  values['pickedLocation'].toString().split(' and ').first),
              double.parse(
                  values['pickedLocation'].toString().split(' and ').last),
            ),
          );
          addressesData.add(address);
        });
      }
    });

    return addressesData;
    // ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<bool> addNewOrder({@required ServiceObject service}) async {
    bool done = false;
    DatabaseReference dbf = firebaseDatabase.ref();
    final User currentUser = FirebaseAuth.instance.currentUser;
    String userUID = currentUser.uid;

    try {
      String rideKey = dbf.push().key;

      Map<String, dynamic> rideData = {
        'userUID': userUID,
        'companyName': service.company.companyName,
        'email': service.company.email,
        'phoneNumber': service.company.phoneNumber,
        'imageName': service.company.imageName,
        'pickedLocation':
            '${service.selectedAddress.pickedLocation.latitude} and ${service.selectedAddress.pickedLocation.longitude}',
        'pickupLocationAddress': service.selectedAddress.pickupLocationAddress,
        'addressType': service.selectedAddress.addressType,
        'selectedDate': service.selectedDate.toString(),
        'selectedTime':
            '${service.selectedTime.hour}:${service.selectedTime.minute}',
        'price': service.price,
        'paymentType': service.paymentType,
        'orderStatus': 'PENDING',
      };

      Map<String, dynamic> userRideData = {
        'orderId': rideKey,
      };
      Map<String, dynamic> companyRideData = {
        'orderId': rideKey,
      };

      await dbf
          .child('Orders')
          .child('OrdersDetails')
          .child(rideKey)
          .set(rideData)
          .then((value1) async => {
                await dbf
                    .child('Orders')
                    .child('UserOrders')
                    .child(userUID)
                    .child(rideKey)
                    .set(userRideData)
                    .then((value2) async => {
                          await dbf
                              .child('Orders')
                              .child('CompanyOrders')
                              .child(service.company.udid)
                              .child(rideKey)
                              .set(companyRideData)
                              .then((value) => {
                                    service.selectedCars
                                        .forEach((carData) async {
                                      Map<String, dynamic> carsData = {
                                        'carModel': carData.carModel,
                                        'carNumber': carData.carNumber,
                                        'carBrand': carData.carBrand,
                                      };
                                      await dbf
                                          .child('Orders')
                                          .child('OrdersDetails')
                                          .child(rideKey)
                                          .child('carsList')
                                          .push()
                                          .set(carsData);
                                    }),
                                    service.selectedServiceTypes
                                        .forEach((servicesData) async {
                                      Map<String, dynamic> carsData = {
                                        'iconData': servicesData.iconData,
                                        'serviceTypeLabel':
                                            servicesData.serviceTypeLabel,
                                        'serviceTypeAmount':
                                            servicesData.serviceTypeAmount,
                                      };
                                      await dbf
                                          .child('Orders')
                                          .child('OrdersDetails')
                                          .child(rideKey)
                                          .child('servicesList')
                                          .push()
                                          .set(carsData);
                                    }),
                                    done = true,
                                  })
                        }),
              });
           getRiderId(service.company.udid);
           print("company id"+service.company.udid.toString());
      return done;
    } catch (e) {
      print("Here");
      print(e);
      return false;
    }
  }

  Future<List<String>> getCustomerOrdersIds() async {
    List<String> userRidesIds = [];
    String userUid = FirebaseAuth.instance.currentUser.uid;

    DatabaseReference userRidesDbf = firebaseDatabase
        .ref()
        .child('Orders')
        .child('UserOrders')
        .child(userUid);

    await userRidesDbf.once().then(
      (snapshot) {
        Map<dynamic, dynamic> values = snapshot.snapshot.value;

        if (values != null) {
          values.forEach(
            (rideKey, rideValue) async {
              userRidesIds.add(rideKey);
            },
          );
        }
      },
    );
    return userRidesIds;
    // ..sort((a, b) => a.locationName.compareTo(b.locationName));
  }

  Future<List<CompanyObject>> getCompaniesList() async {
    List<CompanyObject> companiesData = [];
    print("database ref"+firebaseDatabase.ref().path);
    DatabaseReference dbf = firebaseDatabase.ref().child('Companies');
    await dbf.once().then((snapshot) {
      Map<dynamic, dynamic> value = snapshot.snapshot.value;
      if (value != null) {
        value.forEach((key, values) {
          CompanyObject company = CompanyObject(
            id: key,
            udid: key,
            companyName: values['companyName'],
            email: values['email'],
            password: values['password'],
            address: values['address'],
            imageName: values['imageName'],
            phoneNumber: values['phoneNumber'].toString(),
            city: values['city'],
            state: values['state'],
            rating: double.parse(values['rating'].toString()),
            currentLocation: values['onlineStatus']
                ? LatLng(
                    double.parse(values['currentLocation']
                        .toString()
                        .split(' and ')
                        .first),
                    double.parse(values['currentLocation']
                        .toString()
                        .split(' and ')
                        .last),
                  )
                : null,
            zipCode: values['zipCode'],
            online: values['onlineStatus'],
            amountEarned: double.parse(
              values['amountEarned'].toString(),
            ),
            orders: int.parse(
              values['orders'].toString(),
            ),
            joiningDate: DateTime.parse(
              values['joiningDate'].toString(),
            ),
          );

          if (values['onlineStatus']) {
            companiesData.add(company);
          }
        });
      }
    });

    return companiesData;
    // ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<ServiceTypeObject>> getServices() async {
    List<ServiceTypeObject> servicesData = [];
    DatabaseReference dbf = firebaseDatabase.ref().child('Services');

    await dbf.once().then((snapshot) {
      Map<dynamic, dynamic> value = snapshot.snapshot.value;
      if (value != null) {
        value.forEach((key, values) {
          ServiceTypeObject service = ServiceTypeObject(
            id: key,
            serviceTypeAmount: double.parse(
              values['serviceTypeAmount'].toString(),
            ),
            serviceTypeLabel: values['serviceTypeLabel'],
            iconData: values['iconData'],
          );
          print('values are $values');

          servicesData.add(service);
        });
      }
    });
    return servicesData;
    // ..sort((a, b) => a.joiningDate.compareTo(b.joiningDate))
  }

  Future<bool> addCompanyToFavourite(String companyId) async {
    DatabaseReference dbf = firebaseDatabase.ref();
    bool done = false;

    try {
      Map<String, dynamic> serviceData = {
        'companyId': companyId,
      };
      await dbf
          .child('FavouriteCompanies')
          .child(FirebaseAuth.instance.currentUser.uid)
          .child(companyId)
          .set(serviceData)
          .then(
            (value) async => {
              done = true,
            },
          );

      return done;
    } catch (e) {
      print("Add Service Error");
      print(e);
      return null;
    }
  }

  Future<bool> removeCompanyToFavourite(String companyId) async {
    DatabaseReference dbf = firebaseDatabase.ref();
    bool done = false;

    try {
      await dbf
          .child('FavouriteCompanies')
          .child(FirebaseAuth.instance.currentUser.uid)
          .child(companyId)
          .remove()
          .then(
            (value) async => {
              done = true,
            },
          );

      return done;
    } catch (e) {
      print("Add Service Error");
      print(e);
      return null;
    }
  }

  Future<List<String>> getFavouriteCompanies() async {
    List<String> favourites = [];
    DatabaseReference dbf = firebaseDatabase
        .ref()
        .child('FavouriteCompanies')
        .child(FirebaseAuth.instance.currentUser.uid);

    await dbf.once().then((snapshot) {
      Map<dynamic, dynamic> value = snapshot.snapshot.value;
      if (value != null) {
        value.forEach((key, values) {
          favourites.add(values['companyId']);
        });
      }
    });
    return favourites;
    // ..sort((a, b) => a.joiningDate.compareTo(b.joiningDate))
  }

  Future<bool> makeOrderComplete({@required ServiceObject service}) async {
    bool done = false;
    DatabaseReference dbf = firebaseDatabase.ref();

    try {
      Map<String, dynamic> rideData = {
        'orderStatus': 'COMPLETED',
      };
      await dbf
          .child('Orders')
          .child('OrdersDetails')
          .child(service.id)
          .update(rideData)
          .then((value) => {
                done = true,
              });

      return done;
    } catch (e) {
      print("Here");
      print(e);
      return false;
    }
  }

  void getRiderId(String udid) async{
    try {
      DatabaseReference dbf = firebaseDatabase
          .ref()
          .child('notification_ids')
          .child(udid);

      await dbf.once().then((snapshot) {
        Map<dynamic, dynamic> values = snapshot.snapshot.value;
        var result = values['one_id'];
        List<String> ids = [result];
        sendNotification(ids,'You get a booking',' Order Alert');
        print("One signal id"+result.toString());
      });
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}



Future<Response> sendNotification(List<String> tokenIdList, String contents, String heading) async{
  return await post(
    Uri.parse('https://onesignal.com/api/v1/notifications'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>
    {
      "app_id": oneSignalAppId,//kAppId is the App Id that one get from the OneSignal When the application is registered.

      "include_player_ids": tokenIdList,//tokenIdList Is the List of All the Token Id to to Whom notification must be sent.

      // android_accent_color reprsent the color of the heading text in the notifiction
      "android_accent_color":"FF9976D2",

      "small_icon":"https://cdn.vectorstock.com/i/1000x1000/26/91/auto-detailing-dry-cleaning-motor-man-washing-vector-42922691.webp",

      "large_icon":"https://cdn.vectorstock.com/i/1000x1000/49/66/automatic-car-wash-icon-vector-11514966.webp",

      "headings": {"en": heading},

      "contents": {"en": contents},
    }),
  ).then((value) {
  });
}
