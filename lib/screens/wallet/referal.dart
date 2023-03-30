import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/Model/referal_transaction_model.dart';
import 'package:nearbii/constants.dart';
import 'package:velocity_x/velocity_x.dart';

class Referal extends StatefulWidget {
  const Referal({super.key});

  @override
  State<Referal> createState() => _ReferalState();
}

class _ReferalState extends State<Referal> {
  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);

  var lastDocument;

  bool more = true;
  @override
  void initState() {
    checkAndCreateReferal();
    getReferalHistory();
    super.initState();
  }

  String referCode = "";
  int referBalance = 0;

  checkAndCreateReferal() async {
    if (!Notifcheck.userDAta.containsKey("referCode") ||
        Notifcheck.userDAta["referCode"].toString().isEmptyOrNull) {
      referCode = FirebaseAuth.instance.currentUser!.uid.substring(5, 10);
      await Notifcheck.api.updateUserData(uid, {"referCode": referCode});
    } else {
      referCode = Notifcheck.userDAta["referCode"];
    }
    if (!Notifcheck.userDAta.containsKey("referBalance") ||
        Notifcheck.userDAta["referBalance"].toString().isEmptyOrNull) {
      referBalance = 0;
      await Notifcheck.api.updateUserData(uid, {"referBalance": referBalance});
    } else {
      referCode = Notifcheck.userDAta["referBalance"];
    }
    log(referCode);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: "Referals".text.black.make(),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: kLoadingScreenTextColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 20),
                    child: Container(
                      height: 30,
                      width: 100,
                      decoration: BoxDecoration(
                        color: kSignInContainerColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "₹ $referBalance",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ).px12(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 20),
                    child: Container(
                      height: 30,
                      width: 100,
                      decoration: BoxDecoration(
                        color: kSignInContainerColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Withdraw",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ).onInkTap(() {
                              Fluttertoast.showToast(
                                  msg: "Withdraw fuction Coming Soon");
                            }),
                          ],
                        ),
                      ).px12(),
                    ).onInkTap(() {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: ((context) {
                        return const Referal();
                      })));
                    }),
                  ),
                ],
              ),
              referCode.text.lg.cyan500.underline.makeCentered().onInkTap(() {
                final data = ClipboardData(text: referCode);
                Clipboard.setData(data);
              }).py(10),
              "Your Link $referCode".text.lg.makeCentered().onInkTap(() {
                FlutterShare.share(
                    title: "NearBii Referal Link",
                    text: referCode,
                    linkUrl: "share.com/$referCode");
              }),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 20),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 100,
                  child: ListView.separated(
                      itemCount: referalTransactions.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var value = referalTransactions[index];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    value.referdTo
                                        .toString()
                                        .text
                                        .lg
                                        .bold
                                        .make(),
                                    DateTime.fromMillisecondsSinceEpoch(
                                            value.timestamp)
                                        .toString()
                                        .text
                                        .make(),
                                  ],
                                ),
                                Column(
                                  children: [
                                    (!value.isVendor ? "User" : "Vendor")
                                        .text
                                        .color(value.isVendor
                                            ? Colors.green
                                            : Colors.red)
                                        .bold
                                        .lg
                                        .make()
                                        .pOnly(bottom: 5),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(
                            color: Colors.black,
                          )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<ReferalTransactionModel> referalTransactions = [];
  getReferalHistory() async {
    var snap = FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .collection("referalWallet")
        .orderBy("timestamp", descending: true);
    if (lastDocument != null) {
      snap = snap.startAfterDocument(lastDocument);
    }
    QuerySnapshot<Map<String, dynamic>> snapshot = await snap.limit(5).get();
    if (snapshot.docs.isNotEmpty) {
      more = true;
      lastDocument = snapshot.docs.last;
      for (var referal in snapshot.docs) {
        referalTransactions
            .add(ReferalTransactionModel.fromMap(referal.data()));
      }
      setState(() {});
    } else {
      more = false;
      setState(() {});
    }
  }
}
