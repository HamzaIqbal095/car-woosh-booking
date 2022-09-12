import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:woooosh/Firebase/FirebaseDataBaseService.dart';
import 'package:woooosh/Firebase/FirebaseStorageService.dart';
import 'package:woooosh/Objects/CarObject.dart';
import 'package:woooosh/Utils/Colors.dart';
import 'package:woooosh/Utils/CustomInputStyles.dart';
import 'package:woooosh/Utils/Global.dart';
import 'package:woooosh/Utils/UtilWidgets.dart';
import 'package:woooosh/Utils/validators.dart';

class AddNewCarScreen extends StatefulWidget {
  @override
  _AddNewCarScreenState createState() => _AddNewCarScreenState();
}

class _AddNewCarScreenState extends State<AddNewCarScreen> {
  GlobalKey<FormState> _addCarKey = GlobalKey<FormState>();
  bool switchControl = false;
  bool buttonLoading = false;
  List<String> numbers = [];
  String numbersText = '1';

  void setNumbers() {
    for (var i = 1; i <= 99; i++) {
      numbers.add('$i');
    }
  }

  CarObject _car = CarObject();

  @override
  void initState() {
    setNumbers();
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
                label: 'Add New Car',
                function: () => Navigator.pop(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _addCarKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              decoration: _car.carImage != null
                                  ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: const Color(0x60424152),
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: FileImage(_car.carImage),
                                      ),
                                    )
                                  : BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: const Color(0x60424152),
                                    ),
                              width: MediaQuery.of(context).size.width - 20,
                              height: 200,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    color: greenColor,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: pureWhiteColor,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Enter Car Brand",
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            validator: (value) =>
                                requiredField(value, 'Car Brand'),
                            onSaved: (value) => _car.carBrand = value,
                            decoration: buildCustomInput(
                              hintText: 'Enter Brand Name Here',
                              labelText: null,
                            ),
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Enter Car Model",
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            validator: (carModel) =>
                                requiredField(carModel, 'Car Model'),
                            onSaved: (carModel) => _car.carModel = carModel,
                            decoration: buildCustomInput(
                                hintText: 'Write Some Description',
                                labelText: null),
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Enter Car Type",
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            validator: (value) =>
                                requiredField(value, 'Car Type'),
                            onSaved: (value) => _car.carType = value,
                            decoration: buildCustomInput(
                              hintText: 'Car Type',
                              labelText: null,
                            ),
                            keyboardType: TextInputType.name,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Enter Plate Number",
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 50,
                                child: DropdownButton<String>(
                                  value: numbersText,
                                  items: numbers.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (data) {
                                    setState(() {
                                      numbersText = data;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  validator: (carNumber) =>
                                      requiredField(carNumber, 'Plate Number'),
                                  onSaved: (carNumber) =>
                                      _car.carNumber = carNumber,
                                  decoration: buildCustomInput(
                                    hintText: 'Plate Number',
                                    labelText: null,
                                  ),
                                  keyboardType: TextInputType.name,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          BlackButtonView(
                            context: context,
                            label: '+ Add New Car',
                            function: addNewCar,
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

  Future<void> _pickImage() async {
    File imageSelected;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageSelected = File(pickedFile.path);
    } else {
      print('No image selected.');
    }
    String fileName = imageSelected.path.split('/').last;
//                    String fileDatbaseName = CreateCryptoRandomString(8);

    setState(() {
      _car.carImage = imageSelected;
      _car.imageName = fileName;
    });
  }

  Future<void> addNewCar() async {
    try {
      if (!buttonLoading) {
        if (_addCarKey.currentState.validate()) {
          _addCarKey.currentState.save();
          setState(() {
            _car.carNumber = '$numbersText${_car.carNumber}';
            buttonLoading = true;
          });
          bool fileUploaded;
          if (_car.carImage != null) {
            fileUploaded = await FirebaseStorageService()
                .addCarImageToStorage(_car.carImage);
          } else {
            fileUploaded = true;
          }

          if (fileUploaded) {
            await FirebaseDataBaseService()
                .addNewCar(car: _car)
                .then((value) => {
                      print(value.id),
                      if (value != null) Navigator.of(context).pop(value),
                    });
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
