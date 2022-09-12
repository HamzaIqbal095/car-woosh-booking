import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:woooosh/Firebase/FirebaseDataBaseService.dart';
import 'package:woooosh/Firebase/FirebaseStorageService.dart';
import 'package:woooosh/Objects/UserObject.dart';
import 'package:woooosh/Utils/Colors.dart';
import 'package:woooosh/Utils/CustomInputStyles.dart';
import 'package:woooosh/Utils/Global.dart';
import 'package:woooosh/Utils/UtilWidgets.dart';
import 'package:woooosh/Utils/validators.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserObject _userObject;
  bool buttonLoading = false;

  TextEditingController phoneNumberTextController = TextEditingController();
  TextEditingController userNameTextController = TextEditingController();
  TextEditingController emailAddressTextController = TextEditingController();

  Future<void> getProfile() async {
    setState(() {
      buttonLoading = true;
    });

    UserObject customer = await FirebaseDataBaseService().getSingleUser();
    String customerImageName =
        await FirebaseStorageService().getUserImageLink(customer.userImageName);
    setState(() {
      buttonLoading = false;
      _userObject = customer;
      _userObject.userImageLink = customerImageName;
      phoneNumberTextController.text = _userObject.userPhoneNumber;
      userNameTextController.text = _userObject.userName;
      emailAddressTextController.text = _userObject.userEmail;
    });
  }

  @override
  void initState() {
    getProfile();
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
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        color: backgroundColor,
      ),
      child: _userObject != null
          ? SingleChildScrollView(
              child: Column(
                children: [
                  appBarView(
                    label: 'Profile',
                    function: () => Navigator.pop(context),
                  ),
                  _ImageView(),
                  const SizedBox(
                    height: 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'your Profile Details!',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: dullFontColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      const Text(
                        'Phone Number *',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: dullFontColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          top: 10,
                        ),
                        child: TextFormField(
                          controller: phoneNumberTextController,
                          enabled: false,
                          decoration: buildCustomInput(
                            hintText: 'Phone Number',
                            labelText: null,
                          ),
                          validator: (phoneNumber) =>
                              validatePhoneNumber(phoneNumber),
                          onSaved: (phoneNumber) =>
                              _userObject.userPhoneNumber = phoneNumber,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        'Name *',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: dullFontColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          top: 10,
                        ),
                        child: TextFormField(
                          controller: userNameTextController,
                          keyboardType: TextInputType.name,
                          decoration: buildCustomInput(
                            hintText: 'Name',
                            labelText: null,
                          ),
                          validator: (userName) =>
                              requiredField(userName, 'Name'),
                          onSaved: (userName) =>
                              _userObject.userName = userName,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        'Email Address *',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: dullFontColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          top: 10,
                        ),
                        child: TextFormField(
                          controller: emailAddressTextController,
                          enabled: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: buildCustomInput(
                            hintText: 'Email Address',
                            labelText: null,
                          ),
                          validator: (userEmail) => userEmail.isNotEmpty
                              ? validateEmail(userEmail)
                              : null,
                          onSaved: (userEmail) =>
                              _userObject.userEmail = userEmail,
                        ),
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      // BlackButtonView(
                      //   label: 'Register',
                      //   loading: buttonLoading,
                      //   context: context,
                      //   function: _validateRegisterInput,
                      // ),
                      // const SizedBox(
                      //   height: 15,
                      // ),
                    ],
                  ),
                ],
              ),
            )
          : const Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }

  Widget _ImageView() {
    // print('customer Image name ${_customerObject.customerImageName}');

    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 30),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
            color: pureWhiteColor,
            boxShadow: const [
              BoxShadow(
                color: dullBlueColor,
                blurRadius: 20,
                offset: Offset(0, 0), // Shadow position
              ),
            ],
            borderRadius: BorderRadius.circular(70)),
        padding: const EdgeInsets.all(3),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: _userObject.userImage != null
                      ? FileImage(_userObject.userImage)
                      : (_userObject.userImageLink != null &&
                              _userObject.userImageName != null)
                          ? NetworkImage(_userObject.userImageLink)
                          : const AssetImage('images/default_user.png'),
                ),
                borderRadius: BorderRadius.circular(70),
                color: lightGrayColor,
              ),
              width: 140,
              height: 140,
            ),
            GestureDetector(
              onTap: () => pickImage(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: dullBlueColor,
                    borderRadius: BorderRadius.circular(25)),
                child: buttonLoading
                    ? const CircularProgressIndicator(
                        strokeWidth: 3.0,
                        valueColor: AlwaysStoppedAnimation(
                          greenColor,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt,
                        color: pureWhiteColor,
                        size: 30,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    File image;
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);
    if (pickedFile != null) {
      image = File(pickedFile.path);
    } else {
      print('No image selected.');
    }
    if (image != null) {
      setState(() {
        _userObject.userImage = image;
      });
      _updateProfilePicture();
    }
  }

  Future<void> _updateProfilePicture() async {
    try {
      if (_userObject.userImage != null) {
        setState(() {
          buttonLoading = true;
        });

        // _refresh();s
        FirebaseStorageService().addCustomerImageToStorage(
            _userObject.userUID, _userObject.userImage);

        await FirebaseDataBaseService()
            .editUserProfilePicture(_userObject)
            .then(
              (done) => {
                if (done)
                  {
                    openHomeScreen(context: context),
                  }
              },
            );
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
