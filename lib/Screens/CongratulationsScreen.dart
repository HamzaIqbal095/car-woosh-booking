import 'package:flutter/material.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:woooosh/Firebase/FirebaseDataBaseService.dart';
import 'package:woooosh/Objects/ServiceObjject.dart';
import 'package:woooosh/Screens/AppOpenSplash.dart';
import 'package:woooosh/Utils/Colors.dart';
import 'package:woooosh/Utils/UtilWidgets.dart';

class CongratulationsScreen extends StatefulWidget {
  // final ServiceObject service;
  //
  // const CongratulationsScreen({Key key, @required this.service})
  //     : super(key: key);

  @override
  _CongratulationsScreenState createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen> {
  ServiceObject service;

  _CongratulationsScreenState({@required this.service});

  void _showRatingDialog() {
    // actual store listing review & rating

    final _dialog = RatingDialog(
      initialRating: 1.0,
      starSize: 20,
      // your app's name?
      title: Text(
        'Rating Dialog',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      // encourage your user to leave a high rating?
      message: Text(
        'Please give your feedback',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15),
      ),
      // your app's logo?
      image: Image.asset('images/wooosh_logo.png',height: 70,),
      submitButtonText: 'Submit',
      commentHint: 'Leave your comment',
      onCancelled: () => print('cancelled'),
      onSubmitted: (response) {
        print('rating: ${response.rating}, comment: ${response.comment}');

        // TODO: add your own logic
        if (response.rating > 0.0) {
          FirebaseDataBaseService().AddReview(stars:response.rating.toString(),comment:response.comment.toString());
          // send their comments to your email or anywhere you wish
          // ask the user to contact you instead of leaving a bad review
        }
      },
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: true, // set to false if you want to force a rating
      builder: (context) => _dialog,
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   _showRatingDialog();
    // });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InkWell(
            onTap: (){
            },
            child: _bodyView()),
      ),
    );
  }

  Widget _bodyView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            height: 90,
          ),
          Image.asset(
            'images/tick_logo.png',
            width: MediaQuery.of(context).size.width - 230,
          ),
          Image.asset(
            'images/thank_you_logo.png',
            width: MediaQuery.of(context).size.width - 230,
          ),
          const SizedBox(
            height: 20,
          ),
          // Text(
          //   'Booking Confirmed'.toUpperCase(),
          //   style: const TextStyle(
          //     color: darkBlueColor,
          //     fontSize: 23,
          //     fontWeight: FontWeight.w700,
          //   ),
          // ),
          // const SizedBox(
          //   height: 20,
          // ),
          const Text(
            'Your order hase been successfully placed',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: pureBlackColor,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          // const SizedBox(
          //   height: 20,
          // ),
          // Text(
          //   'Have a great day'.toUpperCase(),
          //   style: const TextStyle(
          //     color: greenColor,
          //     fontSize: 14,
          //     fontWeight: FontWeight.w700,
          //   ),
          // ),
          Column(
            children: [
              BlackButtonView(
                label: 'Go HOME',
                loading: false,
                context: context,
                function: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppOpenSplash(),
                    ),
                    (route) => false),
              ),
              // BlackButtonView(
              //   label: 'My Orders',
              //   loading: false,
              //   context: context,
              //   function: () => Navigator.pushAndRemoveUntil(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => OrdersHistoryScreen(),
              //       ),
              //       (route) => false),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
