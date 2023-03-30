import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/services/transactionupdate/transactionUpdate.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class NearBiiEventsScreen extends StatefulWidget {
  const NearBiiEventsScreen({Key? key}) : super(key: key);

  @override
  State<NearBiiEventsScreen> createState() => _NearBiiEventsScreenState();
}

class _NearBiiEventsScreenState extends State<NearBiiEventsScreen> {
  // static const platform = const MethodChannel("razorpay_flutter");
  late final Razorpay _razorpay = Razorpay();

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    updateTransatcion(
        FirebaseAuth.instance.currentUser!.uid.substring(0, 20),
        "event Memebership plan",
        response.paymentId,
        "success",
        499,
        DateTime.now().millisecondsSinceEpoch);

    updateTransatcion(
        FirebaseAuth.instance.currentUser!.uid.substring(0, 20),
        "Event Memebership plan",
        response.paymentId,
        "success",
        499,
        DateTime.now().millisecondsSinceEpoch);
    // Fluttertoast.showToast(
    //     msg: "SUCCESS: " + response.paymentId!, toastLength: Toast.LENGTH_SHORT);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Fluttertoast.showToast(
    //     msg: "ERROR: " + response.code.toString() + " - " + response.message!,
    //     toastLength: Toast.LENGTH_SHORT);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Fluttertoast.showToast(
    //     msg: "EXTERNAL_WALLET: " + response.walletName!, toastLength: Toast.LENGTH_SHORT);
  }

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() async {
    var options = {
      //TODO:test key when deployment then change key
      // 'key': 'rzp_test_q0FLy0FYnKC94V',
      'key': 'rzp_live_EaquIenmibGbWl',
      'amount': 49900.0,
      'name': 'Acme Corp.',
      'description': 'Fine T-Shirt',
      // 'retry': {'enabled': true, 'max_count': 1},
      // 'send_sms_hash': true,
      // 'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      if (kDebugMode) {
        PaymentSuccessResponse response =
            PaymentSuccessResponse("paymentId", "orderId", "signature");
        _handlePaymentSuccess(response);
      } else {
        _razorpay.open(options);
      }
    } catch (e) {
      debugPrint('Error: e' + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            const SizedBox(
              width: 35,
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: kLoadingScreenTextColor,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Plans  label
              Text(
                "Plans ",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: kLoadingScreenTextColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 45),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: kPlansDescriptionTextColor,
                        offset: Offset.zero,
                        spreadRadius: 0.1,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 26),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "NearBii Events",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: kLoadingScreenTextColor,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            RichText(
                              softWrap: true,
                              text: TextSpan(
                                text: '₹',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: kLoadingScreenTextColor,
                                ),
                                children: [
                                  TextSpan(
                                    text: '999',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20,
                                      color: kLoadingScreenTextColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '/event',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: kLoadingScreenTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "Make yourself visible to every user in the target city",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 11,
                                color: kPlansDescriptionTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 190,
                        width: double.infinity,
                        color: kHomeScreenServicesContainerColor,
                        child: Image.asset(
                            'assets/images/advertise/plans/nearbii_events_image.png'),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 37, 20, 64),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: kSignUpContainerColor,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                const Flexible(
                                  child: Text(
                                    "Event visible to every user in the target city.",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: kSignUpContainerColor,
                                    size: 20,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  const Flexible(
                                    child: Text(
                                      "Push notification to every user in the target city.",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: kSignUpContainerColor,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                const Flexible(
                                  child: Text(
                                    "Event visible in events window and category of event.",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: kSignUpContainerColor,
                                    size: 20,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  const Flexible(
                                    child: Text(
                                      "Pay via payment gateway.",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: kSignUpContainerColor,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                const Flexible(
                                  child: Text(
                                    "Valid till end day of the event. ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                // onTap: () => Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => eventScreens[trueStateIndex],
                //   ),
                // ),
                onTap: () => openCheckout(),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: kSignInContainerColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      "Make Payment",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 61,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
