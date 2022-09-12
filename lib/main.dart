import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:woooosh/Screens/AppOpenSplash.dart';
import 'package:woooosh/Utils/Colors.dart';


final String oneSignalAppId = "";
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initPlatformState();
  runApp(MyApp());
}


/// OneSignal Initialization
Future<void> initPlatformState() async {
  OneSignal.shared.setAppId(oneSignalAppId);
  OneSignal.shared
      .promptUserForPushNotificationPermission()
      .then((accepted) {});
}

class MyApp extends StatelessWidget {
  MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: pureBlackColor),
          backgroundColor: pureWhiteColor,
          titleTextStyle: TextStyle(
            color: pureWhiteColor,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: const ColorScheme.light(
          primary: greenColor, // header background color
          onPrimary: pureWhiteColor, // header text color
          onSurface: darkBlueColor, // body text color
        ),
        primaryColor: Colors.greenAccent,
      ),
      home: AppOpenSplash(),
    );
  }
}
