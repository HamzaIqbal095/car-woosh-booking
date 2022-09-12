import 'package:flutter/material.dart';
import 'package:woooosh/Firebase/FirebaseDataBaseService.dart';
import 'package:woooosh/Objects/ServiceObjject.dart';
import 'package:woooosh/Screens/CongratulationsScreen.dart';
import 'package:woooosh/Utils/Colors.dart';
import 'package:woooosh/Utils/Global.dart';
import 'package:woooosh/Utils/UtilWidgets.dart';

class PaymentScreen extends StatefulWidget {
  final ServiceObject service;

  const PaymentScreen({Key key, @required this.service}) : super(key: key);
  @override
  _PaymentScreenState createState() => _PaymentScreenState(service: service);
}

class _PaymentScreenState extends State<PaymentScreen> {
  ServiceObject service;
  List<String> paymentMethods = ['Cash On Delivery', 'Card'];
  String selectedPaymentMethod = 'Cash On Delivery';

  bool _buttonLoading = false;

  _PaymentScreenState({@required this.service});

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
      child: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                appBarView(
                  label: 'Payment',
                  function: () => Navigator.pop(context),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 35,
                      ),
                      const Text(
                        'Payable Amount  ',
                        style: TextStyle(
                          color: greenColor,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '\$${service.price}',
                        style: const TextStyle(
                          color: greenColor,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Select Payment Method',
                  style: TextStyle(
                    color: pureBlackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: [
                      Icon(
                        service != null
                            ? selectedPaymentMethod == paymentMethods[0]
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off
                            : Icons.radio_button_off,
                        size: 25,
                        color: greenColor,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        paymentMethods[0],
                        style: const TextStyle(
                          color: pureBlackColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          BlackButtonView(
            label: 'Continue',
            context: context,
            loading: _buttonLoading,
            function: _makeOrder,
          )
        ],
      ),
    );
  }

  Future<void> _makeOrder() async {
    if (!_buttonLoading) {
      try {
        setState(() {
          _buttonLoading = true;
        });

        service.paymentType = selectedPaymentMethod;

        await FirebaseDataBaseService()
            .addNewOrder(
              service: service,
            )
            .then((value) => {
                  if (value != null)
                    {
                      showNormalToast(msg: 'Request Submitted!'),
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CongratulationsScreen(
                                // service: service,
                                ),
                          ),
                          (route) => false),
                    }
                });
      } catch (e) {
        print(e.toString());
        setState(() {
          _buttonLoading = false;
        });
      } finally {
        setState(() {
          _buttonLoading = false;
        });
      }
    }
  }
}
