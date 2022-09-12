import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:woooosh/Firebase/FirebaseDataBaseService.dart';
import 'package:woooosh/Objects/MyAddressObject.dart';
import 'package:woooosh/Screens/AddNewAddressScreen.dart';
import 'package:woooosh/Utils/Colors.dart';
import 'package:woooosh/Utils/UtilWidgets.dart';

class MyAddressesScreen extends StatefulWidget {
  @override
  _MyAddressesScreenState createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
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

  @override
  void initState() {
    getAddressesList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodyView(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: darkBlueColor,
        onPressed: () async => {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNewAddressScreen(),
            ),
          ).then(
            (value) async => {
              if (value != null)
                {
                  setState(
                    () {
                      addresses.add(value);
                    },
                  ),
                }
            },
          ),
        },
        child: const Icon(
          Icons.add,
          size: 40,
          color: pureWhiteColor,
        ),
      ),
    );
  }

  Widget _bodyView() {
    return SafeArea(
        child: Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(color: backgroundColor),
      child: Column(
        children: [
          appBarView(
            label: 'My Addresses',
            function: () => Navigator.pop(context),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  return _singleAddressView(index: index);
                }),
          ),
        ],
      ),
    ));
  }

  Widget _singleAddressView({@required int index}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: pureWhiteColor,
        borderRadius: BorderRadius.circular(10),
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
                width: 50,
              ),
              const SizedBox(
                height: 7,
              ),
              Text(
                addresses[index].addressType,
                style: const TextStyle(
                  color: darkBlueColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              )
            ],
          ),
          const SizedBox(
            width: 15,
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
    );
  }
}
