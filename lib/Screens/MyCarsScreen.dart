import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:woooosh/Firebase/FirebaseDataBaseService.dart';
import 'package:woooosh/Firebase/FirebaseStorageService.dart';
import 'package:woooosh/Objects/CarObject.dart';
import 'package:woooosh/Screens/AddNewCarScreen.dart';
import 'package:woooosh/Utils/Colors.dart';
import 'package:woooosh/Utils/UtilWidgets.dart';

class MyCarsScreen extends StatefulWidget {
  @override
  _MyCarsScreenState createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  List<CarObject> cars = [];

  Future<void> getCarsList() async {
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
                          cars.add(
                            CarObject(
                              id: car.id,
                              imageName: value,
                              carBrand: car.carBrand,
                              carModel: car.carModel,
                              carNumber: car.carNumber,
                              carType: car.carType,
                            ),
                          );
                        },
                      ),
                    }
                });
      });
    }
  }

  @override
  void initState() {
    getCarsList();

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
              builder: (context) => AddNewCarScreen(),
            ),
          ).then(
            (value) async => {
              if (value != null)
                {
                  setState(
                    () {
                      cars.add(value);
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
      decoration: const BoxDecoration(color: backgroundColor),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          appBarView(
            label: 'My Cars',
            function: () => Navigator.pop(context),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: cars.length,
                itemBuilder: (context, index) {
                  return _singleCarView(index: index);
                }),
          ),
        ],
      ),
    ));
  }

  Widget _singleCarView({@required int index}) {
    return Container(
      height: 240,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        // color: pureBlackColor,
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          fit: BoxFit.fill,
          image: cars[index].carImage != null
              ? FileImage(cars[index].carImage)
              : NetworkImage(cars[index].imageName ?? 'https://www.pexels.com/photo/blue-bmw-sedan-near-green-lawn-grass-170811/'),
        ),
      ),
      child: Column(
        children: [
          const Expanded(child: SizedBox()),
          Container(
            height: 80,
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Color(0x6033A4C2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      cars[index].carModel,
                      style: const TextStyle(
                        color: pureWhiteColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      cars[index].carBrand,
                      style: const TextStyle(
                        color: pureWhiteColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  cars[index].carNumber,
                  style: const TextStyle(
                    color: pureWhiteColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
