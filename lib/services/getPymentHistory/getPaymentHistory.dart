import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:nearbii/services/transactionupdate/transactionUpdate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../constants.dart';

Widget getPaymentHistory(
    BuildContext context, String uid, DateTime startDate, DateTime endDate) {
  log("wallet");
  try {
    final _firestore = FirebaseFirestore.instance;

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('User')
          .doc(uid)
          .collection("wallet")
          .doc(getDate(startDate.month, startDate.year))
          .snapshots()
          .handleError((error) {
        return Container(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(),
          ),
        );
      }),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData) {
          return "Nothing to Show".text.make().centered().py32();
        }

        List matter = snapshot.data!.get("payments");
        matter.sort((a, b) => b["time"].compareTo(a["time"]));
        print(matter.length);

        return Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.separated(
                itemCount: matter.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
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
                              matter[index]["title"]
                                  .toString()
                                  .text
                                  .lg
                                  .bold
                                  .make(),
                              DateTime.fromMillisecondsSinceEpoch(
                                      matter[index]["time"])
                                  .toString()
                                  .text
                                  .make(),
                            ],
                          ),
                          Column(
                            children: [
                              (matter[index]["status"] ? "Credited" : "Debited")
                                  .text
                                  .color(matter[index]["status"]
                                      ? Colors.green
                                      : Colors.red)
                                  .bold
                                  .lg
                                  .make()
                                  .pOnly(bottom: 5),
                              "Rs.${matter[index]["amount"]}"
                                  .toString()
                                  .text
                                  .bold
                                  .lg
                                  .make(),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) => Divider(
                      color: Colors.black,
                    )),
          ),
        );
      },
    );
  } catch (Ex) {
    print("0x1Error To Get User");
    return Container(
      child: SizedBox(
        child: Center(
          child: Text('Nothing to Show'),
        ),
      ),
    );
  }
}

Widget getPaymentHistoryByDate(
    BuildContext context, String uid, DateTime startDate, DateTime endDate) {
  log("patymentdara");
  try {
    final _firestore = FirebaseFirestore.instance;

    // print("Temp Date");
    // print(DateFormat("yyyy-MM-dd").parse("2022-07-10").microsecondsSinceEpoch ~/
    //     1000);

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('User')
          .doc(uid)
          .collection("payments")
          .doc(getDate(startDate.month, startDate.year))
          .snapshots()
          .handleError((error) {
        return Container(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(),
          ),
        );
      }),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data!.data() == null) {
          return Center(
            child: "Nothing to Show".text.make().centered().py32(),
          );
        }
        if (!snapshot.hasData) {
          return Center(
            child: "Nothing to Show".text.make().centered().py32(),
          );
        }
        List matter = snapshot.data!.get("payments");
        matter.sort((a, b) => b["time"].compareTo(a["time"]));
        print(matter.length);

        return Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.separated(
                itemCount: matter.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
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
                              matter[index]["title"]
                                  .toString()
                                  .text
                                  .medium
                                  .make(),
                              DateTime.fromMillisecondsSinceEpoch(
                                      matter[index]["time"])
                                  .toString()
                                  .text
                                  .make(),
                              "Transaction id : ${matter[index]["id"]}"
                                  .toString()
                                  .text
                                  .color(Colors.grey)
                                  .make(),
                            ],
                          ),
                          Column(
                            children: [
                              matter[index]["status"]
                                  .toString()
                                  .toUpperCase()
                                  .text
                                  .color(Colors.green)
                                  .bold
                                  .lg
                                  .make()
                                  .pOnly(bottom: 5),
                              "Rs.${matter[index]["amount"]}"
                                  .toString()
                                  .text
                                  .bold
                                  .lg
                                  .make(),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) => Divider(
                      color: Colors.black,
                    )),
          ),
        );
      },
    );
  } catch (Ex) {
    print("0x1Error To Get User");
    return Container(
      child: SizedBox(
        child: Center(
          child: "Nothing to Show".text.make().centered().py32(),
        ),
      ),
    );
  }
}

Widget historyBox(
    BuildContext context, String date, String reciptId, int amount) {
  return Container(
    width: MediaQuery.of(context).size.width,
    padding: EdgeInsets.all(20),
    color: Color.fromARGB(255, 190, 220, 245),
    child: Column(
      children: [
        Row(
          children: [
            Text(
              "Initiated on " + date.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: kLoadingScreenTextColor,
              ),
            ),
            Spacer(),
            Text(
              "done",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: kSignInContainerColor,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 3,
        ),
        Row(
          children: [
            Text(
              "Transaction ID: " + reciptId.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: kWalletLightTextColor,
              ),
            ),
            Spacer(),
            Text(
              "₹" + amount.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: kLoadingScreenTextColor,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
