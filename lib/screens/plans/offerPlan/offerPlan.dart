import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/master_screen.dart';
import 'package:nearbii/services/sendNotification/notificatonByCity/cityNotiication.dart';
import 'package:nearbii/services/transactionupdate/transactionUpdate.dart';
import 'package:fluttertoast/fluttertoast.dart';

class offerPlan extends StatefulWidget {
  final Map<String, dynamic> eventInfo;
  final String path;
  const offerPlan({required this.eventInfo, required this.path, Key? key})
      : super(key: key);

  @override
  State<offerPlan> createState() => _offerPlanState();
}

class _offerPlanState extends State<offerPlan> {
  late FirebaseFirestore db;

  late FirebaseStorage storage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadBalance();
  }

  int balance = 0;
  String name = "";
  loadBalance() async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .get()
        .then((value) {
      setState(() {
        balance = value.get("wallet");
        name = value.data()!["name"];
        log(name);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);

  void buyPlane(BuildContext context) async {
    await loadBalance();

    if (balance <= 50) {
      Fluttertoast.showToast(
          msg: "You Don't have 50 coins", toastLength: Toast.LENGTH_LONG);
    } else {
      Fluttertoast.showToast(
          msg: "Posting an offer", toastLength: Toast.LENGTH_LONG);

      Map<String, dynamic> wallet = {};

      wallet["wallet"] = balance - 50;

      await FirebaseFirestore.instance
          .collection('User')
          .doc(uid)
          .update(wallet)
          .then((value) async {
        updateWallet(uid, "Offer Posted", false, 50,
            DateTime.now().millisecondsSinceEpoch, 0);
        var fileName = File(widget.path);

        Reference reference = FirebaseStorage.instance
            .ref()
            .child('vndor/offers/${fileName.absolute.toString()}');
        UploadTask uploadTask = reference.putFile(File(widget.path));
        TaskSnapshot snapshot = await uploadTask;
        var imageUrl = await snapshot.ref.getDownloadURL();

        widget.eventInfo["offerImg"] = imageUrl;

        await FirebaseFirestore.instance
            .collection('Offers')
            .add(widget.eventInfo)
            .then((value) async {
          String myid = value.id;
          await FirebaseFirestore.instance
              .collection('vendor')
              .doc(uid)
              .get()
              .then((value) {
            var time = DateTime.now().millisecondsSinceEpoch;
            name = value.get("businessName");
            FirebaseFirestore.instance.collection("notif").doc(myid).set({
              "id": myid,
              "isOffer": true,
              "uid": widget.eventInfo["uid"],
              "location": value.get("businessLocation"),
              "name": value.get("businessName"),
              "image": value.get("businessImage"),
            });
          });
          Fluttertoast.showToast(msg: "OfferPosted");

          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: ((context) {
            return const MasterPage(
              currentIndex: 0,
            );
          })), (route) => false);
        }).catchError((onError) async {
          Fluttertoast.showToast(
              msg: "Something went Wrong we will Added amount again");

          Map<String, dynamic> wallet = {};

          wallet["wallet"] = balance;

          await FirebaseFirestore.instance
              .collection('User')
              .doc(uid)
              .update(wallet)
              .then((value) {
            Fluttertoast.showToast(msg: "Point added");
          }).catchError((onError) {
            Fluttertoast.showToast(msg: "Something went Wrong use Contact us");
          });
        });

        Fluttertoast.showToast(msg: "Debited 50 point from Wallet");
        sendNotiicationByPin(
            widget.eventInfo["title"],
            FirebaseAuth.instance.currentUser!.uid.substring(0, 20),
            "offer",
            name);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
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
                    padding: const EdgeInsets.only(top: 30, bottom: 25),
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
                                  "NearBii Offers",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    color: kLoadingScreenTextColor,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Redeem 50 points",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: kLoadingScreenTextColor,
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
                            padding: const EdgeInsets.fromLTRB(30, 37, 20, 30),
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
                                        "Publish your poster/post on the offer page. ",
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
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
                                          "Notifications to the user within 3kms around you. ",
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
                                        "Redeem your Nearbii points for publishing offer or buy more via Nearbii wallet. ",
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
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
                                          "Valid for 1 day",
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      buyPlane(context);
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.80,
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(81, 182, 200, 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Make Payment",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
