import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:woooosh/Firebase/FirebaseDataBaseService.dart';
import 'package:woooosh/Firebase/FirebaseStorageService.dart';
import 'package:woooosh/Objects/CompanyObject.dart';
import 'package:woooosh/Objects/ServiceObjject.dart';
import 'package:woooosh/Screens/ConfirmBookingScreen.dart';
import 'package:woooosh/Utils/Colors.dart';

import 'Global.dart';

String time;

Widget BlackButtonView({
  @required String label,
  @required bool loading,
  @required BuildContext context,
  @required Function function,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
    child: Material(
      //Wrap with Material
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      elevation: 18.0,
      color: darkBlueColor,
      clipBehavior: Clip.antiAlias, // Add This
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        height: 50,
        color: darkBlueColor,
        onPressed: function,
        child: loading
            ? const CircularProgressIndicator(
                color: pureWhiteColor,
              )
            : Text(
                label,
                style: const TextStyle(
                  color: pureWhiteColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    ),
  );
}

Widget BlackButtonViewSmall({
  @required String label,
  @required bool loading,
  @required BuildContext context,
  @required Function function,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
    child: Material(
      //Wrap with Material
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      elevation: 18.0,
      color: darkBlueColor,
      clipBehavior: Clip.antiAlias, // Add This
      child: MaterialButton(
        height: 50,
        minWidth: 200.0,
        color: darkBlueColor,
        onPressed: function,
        child: loading
            ? const CircularProgressIndicator(
                color: pureWhiteColor,
              )
            : Text(
                label,
                style: const TextStyle(
                  color: pureWhiteColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    ),
  );
}

Widget ColorButtonView({String label, Color color}) {
  return Container(
    height: 50,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
    alignment: Alignment.center,
    child: Text(
      label,
      style: const TextStyle(
        color: pureWhiteColor,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

Widget BlackButtonSmall({String label, Color color}) {
  return Container(
    height: 30,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
    alignment: Alignment.center,
    child: Text(
      label,
      style: const TextStyle(
        color: pureWhiteColor,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

Widget appBarView({@required String label, @required Function function}) {
  return GestureDetector(
    onTap: function,
    child: Container(
      color: Colors.transparent,
      child: Row(
        children: [
          const Icon(
            Icons.arrow_back_ios,
            color: greenColor,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            label,
            style: const TextStyle(
              color: pureBlackColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    ),
  );
}

class DialogUtilsView extends StatefulWidget {
  final CompanyObject company;
  final ServiceObject service;
  final LatLng currentlocation;
  const DialogUtilsView(
      {Key key, @required this.company, @required this.service,@required this.currentlocation})
      : super(key: key);
  @override
  _DialogUtilsViewState createState() => _DialogUtilsViewState();
}

class _DialogUtilsViewState extends State<DialogUtilsView> {
  @override
  Widget build(BuildContext context) {
    return dialogBody(company: widget.company, service: widget.service,currentlocation: widget.currentlocation);
  }

  Widget dialogBody({@required CompanyObject company, ServiceObject service,LatLng currentlocation}) {
    if(service.selectedAddress != null && service.selectedAddress.pickedLocation.latitude !=null){
      getDistanceMatrix(lat1: service.selectedAddress.pickedLocation.latitude == null ? currentlocation.latitude : service.selectedAddress.pickedLocation.latitude,
          lat2: company.currentLocation.latitude == null ? currentlocation.longitude : service.selectedAddress.pickedLocation.longitude ,
          lon1: company.currentLocation.longitude, lon2:
          service.selectedAddress.pickedLocation.longitude);
    }
    return FutureBuilder(
        future: FirebaseStorageService().getImageLink(
            imageName: company.imageName, folderName: 'Companies'),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.data != null) {
            return Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  height: 180,
                  padding: const EdgeInsets.only(left: 15,right: 15.0,top: 5.0),
                  width: MediaQuery.of(context).size.width / 1.1,
                  decoration: BoxDecoration(
                    color: pureWhiteColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              image: DecorationImage(
                                image: NetworkImage(snapshot.data),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                company.companyName.toUpperCase(),
                                style: const TextStyle(
                                  color: darkBlueColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                company.address,
                                style: const TextStyle(
                                  color: dullFontColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Row(
                          children: [
                            service != null
                                ? service.selectedAddress != null
                                ? service.selectedAddress.pickedLocation !=
                                null ? currentlocation != null
                                ? Row(
                              children: [
                                Column(
                                  children: [
                                    const Text(
                                      'Distance',
                                      style: TextStyle(
                                        color: dullFontColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      '${calculateDistance(lat1: company.currentLocation.latitude, lat2: service.selectedAddress.pickedLocation.latitude, lon1: company.currentLocation.longitude, lon2: service.selectedAddress.pickedLocation.longitude).round()} KM',
                                      style: const TextStyle(
                                        color: pureBlackColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  children: [
                                    const Text(
                                      'Time',
                                      style: TextStyle(
                                        color: dullFontColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: (){
                                        getDistanceMatrix(lat1: service.selectedAddress.pickedLocation.latitude,lat2: company.currentLocation.latitude, lon1: company.currentLocation.longitude, lon2: service.selectedAddress.pickedLocation.longitude);
                                      },
                                      // ignore: prefer_const_constructors
                                      child:  Text(
                                        time ?? "0",
                                        style: const TextStyle(
                                          color: pureBlackColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                                : const SizedBox()
                                : const SizedBox()
                                : const SizedBox()
                                : const SizedBox(),

                            IconButton(
                              onPressed: () =>
                              isCompanyFavourite(companyId: company.id)
                                  ? removeCompanyToFavourites(
                                  companyId: company.id)
                                  : addNewCompanyToFavourites(
                                  companyId: company.id),
                              icon: Icon(
                                isCompanyFavourite(companyId: company.id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: greenColor,
                              ),
                            ),
                          ],
                        ),
                          service != null && service.selectedAddress != null && service.selectedAddress.pickedLocation !=
                              null? Container(
                            child: GestureDetector(
                              onTap: () => {
                                launchUrl(
                                  Uri(
                                    scheme: 'tel',
                                    path: '+923043840004',
                                  ),
                                ),
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: greenColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.call,
                                  color: pureWhiteColor,
                                ),
                              ),
                            ),
                          ):Container(),

                        ],
                      ),
                     SizedBox(height: 5.0,),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         service != null
                             ? BlackButtonViewSmall(
                           label: 'Book Now',
                           loading: false,
                           context: context,
                           function: () => bookNow(
                               context: context, service: service),
                         )
                             : const SizedBox(),


                       ],
                     )
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  width: 70,
                  decoration:  BoxDecoration(
                    color: greenColor,
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.elliptical(
                            MediaQuery.of(context).size.width, 100.0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${company.rating > 0 ? company.rating.toString() : 'new'} ',
                        style: const TextStyle(
                          color: pureWhiteColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const Icon(
                        Icons.star,
                        color: pureWhiteColor,
                        size: 16,
                      )
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const SizedBox();
          }
        });
  }

  Future<void> addNewCompanyToFavourites({@required String companyId}) async {
    try {
      await FirebaseDataBaseService().addCompanyToFavourite(companyId).then(
            (done) => {
              if (done != null)
                {
                  setState(() {
                    favouriteCompanies.add(companyId);
                    showNormalToast(msg: 'Done!');
                  }),
                },
            },
          );
    } on PlatformException catch (e) {
      showNormalToast(msg: e.message);
    } catch (e) {
      showNormalToast(
          msg:
              'The connection failed because the device is not connected to the internet');
    }
  }

  Future<void> removeCompanyToFavourites({@required String companyId}) async {
    try {
      await FirebaseDataBaseService().removeCompanyToFavourite(companyId).then(
            (done) => {
              if (done != null)
                {
                  setState(() {
                    favouriteCompanies.remove(companyId);
                    showNormalToast(msg: 'Done!');
                  }),
                },
            },
          );
    } on PlatformException catch (e) {
      showNormalToast(msg: e.message);
    } catch (e) {
      showNormalToast(
          msg:
              'The connection failed because the device is not connected to the internet');
    }
  }

  void bookNow(
      {@required BuildContext context, @required ServiceObject service}) {
    if (service.company != null && service.selectedCars.isNotEmpty) {
      if (service.selectedServiceTypes.isNotEmpty) {
        if (service.selectedTime != null) {
          if (service.selectedDate != null) {
            if (service.selectedAddress != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfirmBookingScreen(
                    service: service,
                  ),
                ),
              );
            } else {
              showNormalToast(msg: ' Please Chose Address First!');
            }
          } else {
            showNormalToast(msg: ' Please Chose Date First!');
          }
        } else {
          showNormalToast(msg: ' Please Chose Time First!');
        }
      } else {
        showNormalToast(msg: ' Please Chose Service Type First!');
      }
    } else {
      showNormalToast(msg: ' Please Chose Car First!');
    }
  }
}


class DialogUtils {
  static DialogUtils _instance = new DialogUtils.internal();

  DialogUtils.internal();

  factory DialogUtils() => _instance;

  static void showCustomDialog(BuildContext context,
      {@required CompanyObject company, ServiceObject service,LatLng currentlocation}) {
    showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            child: DialogUtilsView(company: company, service: service, currentlocation: currentlocation),
          );
        });
  }
}

bool isCompanyFavourite({@required String companyId}) {
  bool done = false;
  print('length is ${favouriteCompanies.length}');
  favouriteCompanies.forEach((company) {
    if (company == companyId) {
      done = true;
    }
  });

  return done;
}



