import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:woooosh/Firebase/FirebaseDataBaseService.dart';
import 'package:woooosh/Objects/LoginUserObject.dart';
import 'package:woooosh/Screens/SignupScreen.dart';
import 'package:woooosh/Screens/UserVerifyOtpScreen.dart';
import 'package:woooosh/Utils/Colors.dart';
import 'package:woooosh/Utils/CustomInputStyles.dart';
import 'package:woooosh/Utils/Global.dart';
import 'package:woooosh/Utils/UtilWidgets.dart';
import 'package:woooosh/Utils/validators.dart';

import '../Firebase/PhoneAuthService.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneNumberTextController = TextEditingController();
  LoginUserObject loginUserObject = LoginUserObject();
  GoogleSignInAccount _currentUser;

  bool buttonLoading = false;
  String phoneNumber = "", verificationId;
  String isoCode = "", _contactText;
  bool codeSent = false;
  // CountryCode selectedCountry;

  @override
  void initState() {
    phoneNumberTextController.text = '+971';
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
      // decoration: const BoxDecoration(color: pureWhiteColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const SizedBox(
                height: 60,
              ),
              appLogo,
              const SizedBox(
                height: 100,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Phone Number',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: pureBlackColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextFormField(
                    controller: phoneNumberTextController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: pureBlackColor),
                    decoration: buildCustomInput(
                        hintText: 'Phone Number', labelText: null),
                    validator: (phoneNumber) =>
                        validatePhoneNumber(phoneNumber),
                    onSaved: (phoneNumber) =>
                        loginUserObject.phoneNumber = phoneNumber,
                  ),
                  const Text(
                    'Phone e.g +971500000000',
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
                  BlackButtonView(
                    label: 'Continue',
                    loading: buttonLoading,
                    context: context,
                    function: sendOTP,
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                const Text(
                  'or Continue With',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: dullFontColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  onTap: _signInWithGoogle,
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: pureBlackColor,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          FontAwesomeIcons.google,
                          color: greenColor,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Google',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: dullFontColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User _user;
  Future<User> _signInWithGoogle() async {
    // model.state = ViewState.Busy;

    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();

    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    await _auth.signInWithCredential(credential).then((value) async => {
          _user = value.user,
          await FirebaseDataBaseService().getSingleUser().then(
                (value1) => {
                  value1 != null
                      ? {
                          showNormalToast(msg: 'Welcome Back'),
                          openHomeScreen(context: context),
                          // getDeviceTokenForCustomer(user.uid),
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => HomeScreen(),
                          //   ),
                          // )
                        }
                      : {
                          // if (phone != null)
                          //   {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(
                                phoneNumber: null,
                                email: _user.email,
                                // country: country,
                              ),
                            ),
                          )
                          // }
                        },
                },
              ),
        });
    //
    //
    // assert(!_user.isAnonymous);
    //
    // assert(await _user.getIdToken() != null);
    //
    // FirebaseUser currentUser = await _auth.currentUser();
    //
    // assert(_user.uid == currentUser.uid);
    //
    // model.state = ViewState.Idle;

    print("User Name: ${_user.displayName}");
    print("User Email ${_user.email}");
  }

  Future<void> sendOTP() async {
    // Send OTP Code to your phone
    try {
      setState(() {
        buttonLoading = true;
      });
      if (phoneNumberTextController.text.isEmpty) {
        showNormalToast(msg: 'Invalid_phone_number');
        setState(() {
          buttonLoading = false;
        });
        return;
      } else {
        if (phoneNumberTextController.text != null) {
          verifyPhone(phoneNumberTextController.text);
        } else {
          setState(() {
            buttonLoading = false;
          });
        }
      }
    } on PlatformException catch (e) {
      print('some thing ${e.toString()}');
      setState(() {
        buttonLoading = false;
      });
    } catch (e) {
      print('some thing ${e.toString()}');
      setState(() {
        buttonLoading = false;
      });
    }
  }

  Future<void> verifyPhone(phoneNo) async {
    try {
      print('m called $phoneNo');

      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNo,
          timeout: const Duration(seconds: 5),
          verificationCompleted: (authResult) {
            FirebaseAuthService().signIn(
              authCreds: authResult,
              context: context,
              phone: phoneNo,
            );
          },
          verificationFailed: (authException) {
            showNormalToast(msg: authException.message);
            print('authException: ${authException.message}');
            print('authException: ${authException.toString()}');
          },
          codeSent: (String verId, [int forceResend]) {
            verificationId = verId;
            setState(() {
              codeSent = true;
              buttonLoading = false;
            });
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserVerifyOtpScreen(
                  phoneNumber: phoneNumberTextController.text,
                  verificationId: verificationId,
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verId) {
            verificationId = verId;
          });
    } catch (e) {
      print('some thing 11 ${e.toString()}');
      setState(() {
        buttonLoading = false;
      });
    }
  }
}
