import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:woooosh/Firebase/PhoneAuthService.dart';
import 'package:woooosh/Utils/Colors.dart';
import 'package:woooosh/Utils/Global.dart';
import 'package:woooosh/Utils/UtilWidgets.dart';

class UserVerifyOtpScreen extends StatefulWidget {
  final String phoneNumber, verificationId;

  const UserVerifyOtpScreen(
      {Key key, @required this.phoneNumber, @required this.verificationId})
      : super(key: key);

  @override
  _UserVerifyOtpScreenState createState() => _UserVerifyOtpScreenState();
}

class _UserVerifyOtpScreenState extends State<UserVerifyOtpScreen> {
  final GlobalKey<FormState> _OTPFormKey = GlobalKey<FormState>();
  String smsCode;
  bool buttonLoading = false;

  String verificationId;
  bool codeSent = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(30),
            color: pureWhiteColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                appBarView(
                  label: 'Verification',
                  function: () => Navigator.pop(context),
                ),
                const SizedBox(
                  height: 50,
                ),
                // sandiateLogo,
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  'Verification Code',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: dullFontColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Image.asset(
                  'images/wooosh_logo.png',
                  width: 200,
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  'We just send you text message 2FA code ${widget.phoneNumber}. please enter it now',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: dullFontColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                formArea(),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t receive the OTP?  ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: dullFontColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    GestureDetector(
                      // onTap: () => sendOTP(),
                      // onTap: () => Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => LoginScreen(),
                      //   ),
                      // ),
                      child: Container(
                        color: Colors.transparent,
                        child: const Text(
                          'Resend 2FA',
                          style: TextStyle(
                            fontSize: 13,
                            color: orangeColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                BlackButtonView(
                  label: 'Submit',
                  loading: buttonLoading,
                  context: context,
                  function: () {
                    if (!buttonLoading) {
                      signInUser();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget formArea() {
    return Form(
      key: _OTPFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  PinCodeTextField(
                    length: 6,
                    appContext: context,
                    obscureText: false,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderWidth: 1,
                      borderRadius: BorderRadius.circular(10),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      inactiveFillColor: const Color(0xFFF4F4F4),
                      activeColor: const Color(0xFFF4F4F4),
                      selectedFillColor: const Color(0xFFF4F4F4),
                      inactiveColor: const Color(0xFFF4F4F4),
                      selectedColor: const Color(0xFFF4F4F4),
                      activeFillColor: const Color(0xFFF4F4F4),
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    onCompleted: (value) {
                      print("Completed");
                      setState(() {
                        smsCode = value;
                      });
                    },
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        smsCode = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      print("Allowing to paste $text");
                      //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                      //but you can show anything you want here, like your pop up saying wrong paste format or etc
                      return true;
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void signInUser() {
    try {
      if (!buttonLoading) {
        setState(() {
          buttonLoading = true;
        });
        if (_OTPFormKey.currentState.validate()) {
          _OTPFormKey.currentState.save();
          if (smsCode != null) {
            FirebaseAuthService().signInWithOTP(
              smsCode: smsCode,
              verId: widget.verificationId,
              phone: widget.phoneNumber,
              context: context,
            );
          } else {
            setState(() {
              buttonLoading = false;
            });
          }
        } else {
          setState(() {
            buttonLoading = false;
          });
        }
      } else {
        showNormalToast(msg: 'Please Wait!');
      }
    } on PlatformException catch (e) {
      print(e.message);
      setState(() {
        buttonLoading = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        buttonLoading = false;
      });
    }
  }

  Future<void> sendOTP() async {
    // Send OTP Code to your phone
    try {
      setState(() {
        buttonLoading = true;
      });
      if (widget.phoneNumber.isEmpty) {
        showNormalToast(msg: 'Invalid_phone_number');
        setState(() {
          buttonLoading = false;
        });
        return;
      } else {
        if (widget.phoneNumber != null) {
          verifyPhone(widget.phoneNumber);
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
      print('m called $phoneNo.');

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
            setState(() {
              buttonLoading = false;
            });
            print('authException: ${authException.message}');
          },
          codeSent: (String verId, [int forceResend]) {
            verificationId = verId;
            setState(() {
              codeSent = true;
              buttonLoading = false;
            });
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => UserVerifyOtpScreen(
                  phoneNumber: widget.phoneNumber,
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
