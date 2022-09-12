import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:woooosh/Screens/LoginScreen.dart';
import 'package:woooosh/Utils/Colors.dart';
import 'package:woooosh/Utils/Global.dart';

class AppOpenSplash extends StatefulWidget {
  @override
  _AppOpenSplashState createState() => _AppOpenSplashState();
}

class _AppOpenSplashState extends State<AppOpenSplash> {
  User firebaseUser = FirebaseAuth.instance.currentUser;

  // List<CompanyObject> companies = [];

  void initState() {
    super.initState();
    firebaseUser != null
        ? openHomeScreen(context: context)
        : Future.delayed(
            const Duration(seconds: 4),
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: orangeColor,
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage(
              'images/splash.jpg',
            ),
          ),
        ),
        // child: Center(
        //   child: Image.asset(
        //     'images/sendiate.png',
        //     width: 380,
        //   ),
        // ),
      ),
    );
  }
}
