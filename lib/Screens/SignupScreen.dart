import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:woooosh/Firebase/FirebaseDataBaseService.dart';
import 'package:woooosh/Objects/UserObject.dart';
import 'package:woooosh/Utils/Colors.dart';
import 'package:woooosh/Utils/CustomInputStyles.dart';
import 'package:woooosh/Utils/Global.dart';
import 'package:woooosh/Utils/UtilWidgets.dart';
import 'package:woooosh/Utils/validators.dart';

class SignupScreen extends StatefulWidget {
  final String phoneNumber;
  final String email;

  const SignupScreen({
    Key key,
    @required this.phoneNumber,
    @required this.email,
  }) : super(key: key);
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController phoneNumberTextController = TextEditingController();
  TextEditingController userNameTextController = TextEditingController();
  TextEditingController emailAddressTextController = TextEditingController();
  UserObject loginUserObject = UserObject();
  bool buttonLoading = false, phoneField, emailField;
  final GlobalKey<FormState> _signupFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    setState(() {
      loginUserObject.userPhoneNumber = widget.phoneNumber;
      loginUserObject.userEmail = widget.email;
      phoneNumberTextController.text = widget.phoneNumber;
      emailAddressTextController.text = widget.email;
      print('${widget.email}  ${widget.phoneNumber}');

      phoneField = widget.phoneNumber != null ? false : true;
      emailField = widget.email != null ? false : true;
    });

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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(color: pureWhiteColor),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Form(
              key: _signupFormKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    appLogo,
                    const SizedBox(
                      height: 40,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Please enter your details',
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
                            enabled: phoneField,
                            decoration: buildCustomInput(
                              hintText: 'Phone Number',
                              labelText: null,
                            ),
                            validator: (phoneNumber) =>
                                validatePhoneNumber(phoneNumber),
                            onSaved: (phoneNumber) =>
                                loginUserObject.userPhoneNumber = phoneNumber,
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
                                loginUserObject.userName = userName,
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
                            enabled: emailField,
                            controller: emailAddressTextController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: buildCustomInput(
                              hintText: 'Email Address',
                              labelText: null,
                            ),
                            validator: (userEmail) => userEmail.isNotEmpty
                                ? validateEmail(userEmail)
                                : null,
                            onSaved: (userEmail) =>
                                loginUserObject.userEmail = userEmail,
                          ),
                        ),
                        const SizedBox(
                          height: 35,
                        ),
                        BlackButtonView(
                          label: 'Register',
                          loading: buttonLoading,
                          context: context,
                          function: _validateRegisterInput,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _validateRegisterInput() async {
    final FormState form = _signupFormKey.currentState;

    if (form.validate()) {
      form.save();
      setState(() {
        buttonLoading = true;
      });
      try {
        loginUserObject.userUID = FirebaseAuth.instance.currentUser.uid;

        await FirebaseDataBaseService()
            .addNewUser(user: loginUserObject)
            .then((dataUpdated) async => {
                  if (dataUpdated)
                    {
                      openHomeScreen(context: context),
                      // Navigator.pushAndRemoveUntil(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => HomeScreen(),
                      //     ),
                      //     ModalRoute.withName('')),
                    }
                });
        // }
      } catch (error) {
        print(error.code);
        switch (error.code) {
          case "email-already-in-use":
            {
              setState(() {
                buttonLoading = false;
              });
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AlertDialog(
                      content: Text("This email is already in use."),
                    );
                  });
            }
            break;
          case "weak-password":
            {
              setState(() {
                buttonLoading = false;
              });
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AlertDialog(
                      content: Text(
                          "The password must be 6 characters long or more."),
                    );
                  });
            }
            break;
        }
      } finally {
        setState(() {
          buttonLoading = false;
        });
      }
    }
  }
}
