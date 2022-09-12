import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:woooosh/Firebase/FirebaseDataBaseService.dart';
import 'package:woooosh/Objects/UserObject.dart';
import 'package:woooosh/Screens/SignupScreen.dart';
import 'package:woooosh/Utils/Global.dart';

import '../Objects/LoginUserObject.dart';

class FirebaseAuthService {
  //Handles Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  handleAuth() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
//           if (snapshot.data != null) {
//             User user = snapshot.data;
// //            print('user data is ${user.uid}');
//
//             return CustomerHomeScreen(
//               currentCustomer: CustomerObject(customerUID: user.uid),
//             );
//           } else {
// //            print('not user is ${snapshot.toString()}');
//             return CustomerHomeScreen(currentCustomer: CustomerObject());
//           }
        });
  }

  //Sign out
  signOut() {
    FirebaseAuth.instance.signOut();
  }

  signIn(
      {@required AuthCredential authCreds,
      @required BuildContext context,
      @required String phone}) async {
    try {
      print('m called');

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(authCreds);
      final User user = authResult.user;
      await FirebaseDataBaseService().getSingleUser().then(
            (value) => {
              value != null
                  ? {
                      showNormalToast(msg: 'Welcome Back'),
                      // getDeviceTokenForCustomer(user.uid),
                      openHomeScreen(context: context),
                    }
                  : {
                      if (phone != null)
                        {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(
                                phoneNumber: phone,
                                email: null,
                                // country: country,
                              ),
                            ),
                          )
                        }
                    },
            },
          );

//      print('User Id : ' + user.uid);
    } catch (e) {
      print('some thing ${e.toString()}');
      showNormalToast(msg: 'Invalid OTP');
    }
  }

  signInWithOTP({
    @required smsCode,
    @required verId,
    @required String phone,
    @required BuildContext context,
  }) {
    try {
      print('sms code $smsCode $verId');
      AuthCredential authCreds =
          PhoneAuthProvider.credential(verificationId: verId, smsCode: smsCode);
      signIn(
        authCreds: authCreds,
        context: context,
        phone: phone,
      );
    } catch (e) {
      showNormalToast(msg: 'Invalid or Expired OTP!');
    }
  }

  Future<UserObject> loginUser(LoginUserObject userData) async {
    try {
      print('User Name Is : ${userData.email} and pass: ${userData.password}');
      UserCredential user = await _auth.signInWithEmailAndPassword(
          email: userData.email, password: userData.password);
//      SharedPrefs.setStringPreference("uid", user.user.uid);
      print('User Name Is : ${user.user.email} and pass: ${user.user.uid}');
      return UserObject(
        userEmail: user.user.email,
        userUID: user.user.uid,
      );
    } on PlatformException catch (e) {
      print(e);
      throw PlatformException(
        message: "Wrong username / password",
        code: "403",
      );
    } catch (e) {
      return null;
    }
  }
}
