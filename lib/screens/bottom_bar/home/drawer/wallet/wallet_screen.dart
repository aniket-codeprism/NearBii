import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/wallet/transaction_history/transaction_history_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/wallet/wallet_recharge_history_screen.dart';
import 'package:nearbii/services/transactionupdate/transactionUpdate.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:velocity_x/velocity_x.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int addBalance = 0;

  int myBalance = 0;

  int beforeBalance = 0;

  TextEditingController inpBalance = TextEditingController();

  List<int> balanceAmount = [100, 200, 500, 1000];

  late FirebaseFirestore db;

  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);

  late Razorpay _razorpay = Razorpay();

  Map<String, dynamic> walletData = {};

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    updateTransatcion(
        FirebaseAuth.instance.currentUser!.uid.substring(0, 20),
        "Wallet Money Added",
        response.paymentId,
        "success",
        addBalance,
        DateTime.now().millisecondsSinceEpoch);
    setState(() {
      myBalance += addBalance;
    });

    Map<String, dynamic> data = {};

    data["wallet"] = myBalance;

    await FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .update(data)
        .then((value) {
      Fluttertoast.showToast(msg: "Point Added");
    });

    Fluttertoast.showToast(msg: addBalance.toString() + " Point is Added");

    updateWallet(uid, "Points Added", true, addBalance,
        DateTime.now().millisecondsSinceEpoch, myBalance);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "Payment Failed. Event Not Added",
        toastLength: Toast.LENGTH_SHORT);

    //saveToDB();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Fluttertoast.showToast(
    //     msg: "EXTERNAL_WALLET: " + response.walletName!, toastLength: Toast.LENGTH_SHORT);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadBalance();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  loadBalance() async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .get()
        .then((value) {
      setState(() {
        myBalance = value.get("wallet");
        beforeBalance = myBalance;
      });
    });

    var collection = await FirebaseFirestore.instance
        .collection("User")
        .doc(uid)
        .collection("wallet")
        .doc("lastSummary")
        .get();

    try {
      var data = collection.data();

      if (data != null) {
        setState(() {
          walletData["lastRecharge"] = data["lastAmount"];
          walletData["afterRecharge"] = data["currbalce"];
          walletData["beforeRecharge"] = data["bill"];
        });
      }
    } catch (e) {
      print("Something is wrong to get last recharge: " + e.toString());
    }

    // for (var doc in querySnapshot.docs) {
    //   Map<String, dynamic> data = doc.data();
    //   var rate = data['starRate']; // <-- Retrieving the value.

    // }

    // await FirebaseFirestore.instance
    //     .collection('vendor')
    //     .doc(uid)
    //     .collection("wallet")
    //     .get()
    //     .then((value) {
    //   setState(() {
    //     print(value);
    //   });
    // });
  }

  addNewBalance() {
    var amount = addBalance * 100.0;
    var options = {
      //TODO:test key when deployment then change key
      // 'key': 'rzp_test_q0FLy0FYnKC94V',
      'key': 'rzp_live_EaquIenmibGbWl',
      'amount': amount,
      'name': 'NearBii Add to Wallet',
      'description': 'Add points',
      // 'retry': {'enabled': true, 'max_count': 1},
      // 'send_sms_hash': true,
      // 'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e' + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            SizedBox(
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
              //my wallet label
              Text(
                "My Wallet",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: kLoadingScreenTextColor,
                ),
              ),
              //wallet balance
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 20),
                child: Container(
                  height: 71,
                  width: 163,
                  decoration: BoxDecoration(
                    color: kSignInContainerColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Wallet Balance",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "₹ " + myBalance.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //add money label
              Text(
                "Add Money",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: kLoadingScreenTextColor,
                ),
              ),
              //add money container
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kHomeScreenServicesContainerColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 51, 17, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: inpBalance,
                          onChanged: (value) {
                            setState(() {
                              addBalance = int.parse(value.replaceAll("₹", ''));
                            });
                          },
                        ),

                        Divider(
                          color: kSignUpContainerColor,
                        ),
                        SizedBox(
                          width: width,
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: balanceAmount.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    addBalance += balanceAmount[index];

                                    inpBalance.text =
                                        "₹ " + addBalance.toString();
                                  });
                                },
                                child: Container(
                                  width: width / 4 - 23,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(61),
                                    border: Border.all(
                                        color: kWalletScreenContainerColor),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "+ " + balanceAmount[index].toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 11.54,
                                        color: kSignInContainerColor,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) => SizedBox(
                              width: 5,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        //add money button
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              addNewBalance();
                            },
                            child: Container(
                              height: 40,
                              width: 173,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: kSignInContainerColor),
                              child: Center(
                                child: Text(
                                  "Add Money",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TransactionHistoryScreen(false),
                  ),
                ),
                child: Container(
                  height: 71,
                  decoration: BoxDecoration(
                    color: kSignUpContainerColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Image.asset(
                              'assets/icons/wallet/payment 1.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                              child: "Wallet History".text.semiBold.make()),
                        ],
                      ),
                    ),
                  ),
                ).py16(),
              ),
              SizedBox(
                width: 16,
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TransactionHistoryScreen(true),
                  ),
                ),
                child: Container(
                  height: 71,
                  decoration: BoxDecoration(
                    color: kSignUpContainerColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Image.asset(
                              'assets/icons/wallet/bill 1.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          "Transaction History".text.semiBold.make()
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              //wallet summary label
              Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 20),
                child: Text(
                  "Wallet Summary",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: kLoadingScreenTextColor,
                  ),
                ),
              ),
              //wallet summary container
              Padding(
                padding: const EdgeInsets.only(bottom: 155),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kHomeScreenServicesContainerColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(11, 13, 13, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Last recharge amount",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: kLoadingScreenTextColor,
                              ),
                            ),
                            Spacer(),
                            Text(
                              "₹ " + walletData["lastRecharge"].toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: kLoadingScreenTextColor,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Text(
                                "Balance after last recharge",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: kLoadingScreenTextColor,
                                ),
                              ),
                              Spacer(),
                              Text(
                                "₹ " + walletData["afterRecharge"].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: kLoadingScreenTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "Bill before last reacharge",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: kLoadingScreenTextColor,
                              ),
                            ),
                            Spacer(),
                            Text(
                              "₹ " + walletData["beforeRecharge"].toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
