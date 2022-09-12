import 'package:flutter/material.dart';
import 'package:woooosh/Utils/Colors.dart';
import 'package:woooosh/Utils/UtilWidgets.dart';

class ContactUsScreen extends StatefulWidget {
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
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
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appBarView(
            label: 'Contact Us',
            function: () => Navigator.pop(context),
          ),
          const SizedBox(
            height: 40,
          ),
          const Text(
            'We are happy to\nhear from you!!',
            style: TextStyle(
              color: greenColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Text(
            'Let us know about your queries & Feedbacks',
            style: TextStyle(
              color: pureBlackColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 150,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(100.0, 5.0, 0.0, 0.0),
            child: Material(
              //Wrap with Material
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0)),
              elevation: 18.0,
              color: darkBlueColor,
              clipBehavior: Clip.antiAlias, // Add This
              child: MaterialButton(
                minWidth: MediaQuery.of(context).size.width,
                height: 80,
                color: darkBlueColor,
                onPressed: () => {},
                child: const Text(
                  'Call Us',
                  style: TextStyle(
                    color: pureWhiteColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 5.0, 100.0, 0.0),
            child: Material(
              //Wrap with Material
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0)),
              elevation: 18.0,
              color: greenColor,
              clipBehavior: Clip.antiAlias, // Add This
              child: MaterialButton(
                minWidth: MediaQuery.of(context).size.width,
                height: 80,
                color: greenColor,
                onPressed: () => {},
                child: const Text(
                  'Mail Us',
                  style: TextStyle(
                    color: pureWhiteColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(100.0, 5.0, 0.0, 0.0),
            child: Material(
              //Wrap with Material
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0)),
              elevation: 18.0,
              color: pureWhiteColor,
              clipBehavior: Clip.antiAlias, // Add This
              child: MaterialButton(
                minWidth: MediaQuery.of(context).size.width,
                height: 80,
                color: pureWhiteColor,
                onPressed: () => {},
                child: const Text(
                  'Message Us',
                  style: TextStyle(
                    color: dullFontColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
