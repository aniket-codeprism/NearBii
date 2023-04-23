import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/plans/offerPlan/offerPlan.dart';
import 'package:nearbii/services/getcity.dart';
import 'package:velocity_x/velocity_x.dart';

class PostOfferScreen extends StatefulWidget {
  const PostOfferScreen({Key? key}) : super(key: key);

  @override
  State<PostOfferScreen> createState() => _PostOfferScreenState();
}

class _PostOfferScreenState extends State<PostOfferScreen> {
  late FirebaseFirestore db;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    db = FirebaseFirestore.instance;

    // Fluttertoast.showToast(
    //     msg: DateTime.now().microsecondsSinceEpoch.toString());
    getCity();
  }

  String city = "";
  getCity() async {
    city = await getcurrentCityFromLocation();
    if (mounted) {
      setState(() {});
    }
  }

  TextEditingController title = TextEditingController();
  TextEditingController subTitle = TextEditingController();
  TextEditingController off = TextEditingController();

  String offImg = "";
  String cat = "Gaming";

  Map<String, dynamic> offerData = {};

  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);

  Map<String, dynamic> eventLocation = {};

  _imgFromGallery() async {
    XFile? images = await ImagePicker().pickImage(source: ImageSource.gallery);
    //.getImage(source: ImageSource.gallery, imageQuality: 88);
    if (images != null) {
      setState(() {
        offImg = images.path;
      });
    }
  }

  saveOffer() {
    if (title.text.isEmptyOrNull || subTitle.text.isEmptyOrNull) {
      Fluttertoast.showToast(msg: "Please Enter all the Details");
      return;
    } else if (offImg.isEmptyOrNull) {
      Fluttertoast.showToast(msg: "Please Select a Photo");
      return;
    }
    offerData["Title"] = title.text;
    offerData["subTitle"] = subTitle.text;
    offerData["offerImg"] = offImg;
    offerData["city"] = city;
    offerData["off"] = double.parse(title.text);
    offerData["uid"] = uid;
    offerData["date"] = DateTime.now().millisecondsSinceEpoch;
    offerData["location"] = Notifcheck.currentVendor!.businessLocation.toMap();
    offerData["category"] = Notifcheck.currentVendor!.businessCat;

    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return offerPlan(eventInfo: offerData, path: offImg);
    }));
  }

  void updatedTime(String? newValue) {
    setState(() {
      cat = newValue.toString();

      offerData["cat"] = cat;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    var x = MediaQuery.of(context).size.width;

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
                size: 18,
                color: kLoadingScreenTextColor,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  saveOffer();
                },
                child: Text(
                  "Done",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: kLoadingScreenTextColor,
                  ),
                ),
              ),
              const SizedBox(
                width: 34,
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(
                        Notifcheck.currentVendor!.businessImage.isEmptyOrNull
                            ? Notifcheck.defCover
                            : Notifcheck.currentVendor!.businessImage),
                  ),
                  const SizedBox(
                    width: 9,
                  ),
                  Text(
                    Notifcheck.currentVendor!.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 30,
              ),

              // Container(
              //   width: double.infinity,
              //   height: 0.5,
              //   color: kWalletLightTextColor,
              // ),

              SizedBox(
                width: MediaQuery.of(context).size.width * 0.80,
                // margin: EdgeInsets.only(
                //   top: 20,
                // ),
                child: TextField(
                    controller: subTitle,
                    decoration: const InputDecoration(
                      // label: Text("Title"),
                      hintText: "what's on your mind",
                      hintStyle:
                          TextStyle(color: Color.fromARGB(255, 203, 207, 207)),
                      // enabledBorder: OutlineInputBorder(
                      //     borderSide: BorderSide(
                      //   color: Color.fromARGB(173, 125, 209, 248),
                      // )),
                      // focusedBorder: OutlineInputBorder(
                      //   borderSide: const BorderSide(
                      //       color: Color.fromARGB(173, 125, 209, 248),
                      //       width: 1),
                      //   borderRadius: BorderRadius.circular(10),
                      // ),
                      // border: OutlineInputBorder(
                      //   borderSide: const BorderSide(
                      //       color: Color.fromARGB(173, 125, 209, 248),
                      //       width: 1),
                      //   borderRadius: BorderRadius.circular(10),
                      // ),
                    )),
              ),

              // Container(
              //   width: MediaQuery.of(context).size.width * 0.80,
              //   margin: EdgeInsets.only(
              //     top: 20,
              //   ),
              //   child: TextField(
              //       controller: subTitle,
              //       decoration: InputDecoration(
              //         label: Text("SubTitle"),
              //         hintText: "on your product",
              //         hintStyle:
              //             TextStyle(color: Color.fromARGB(255, 203, 207, 207)),
              //         enabledBorder: OutlineInputBorder(
              //             borderSide: BorderSide(
              //           color: Color.fromARGB(173, 125, 209, 248),
              //         )),
              //         focusedBorder: OutlineInputBorder(
              //           borderSide: const BorderSide(
              //               color: Color.fromARGB(173, 125, 209, 248),
              //               width: 1),
              //           borderRadius: BorderRadius.circular(10),
              //         ),
              //         border: OutlineInputBorder(
              //           borderSide: const BorderSide(
              //               color: Color.fromARGB(173, 125, 209, 248),
              //               width: 1),
              //           borderRadius: BorderRadius.circular(10),
              //         ),
              //       )),
              // ),

              // getCatDrop(context),

              InkWell(
                onTap: () {
                  _imgFromGallery();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: MediaQuery.of(context).size.height * 0.50,
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    image: offImg != ""
                        ? DecorationImage(
                            fit: BoxFit.cover, image: FileImage(File(offImg)))
                        : null,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: const Color.fromARGB(173, 125, 209, 248),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          // color: Color.fromRGBO(241, 246, 247, 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 110,
                        height: 110,
                        child: offImg == ""
                            ? const Icon(Icons.add_outlined,
                                size: 60,
                                color: Color.fromRGBO(196, 196, 196, 1))
                            : const SizedBox(),
                      ),
                      offImg == ""
                          ? Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: const Text(
                                "Add Photo",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 203, 207, 207),
                                    fontSize: 18),
                              ))
                          : const SizedBox()
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.80,
                margin: const EdgeInsets.only(
                  top: 20,
                ),
                child: TextField(
                    controller: title,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      // label: Text("Off"),
                      hintText: "60% OFF",
                      hintStyle:
                          TextStyle(color: Color.fromARGB(255, 203, 207, 207)),
                      // enabledBorder: OutlineInputBorder(
                      //     borderSide: BorderSide(
                      //       color: Color.fromARGB(173, 125, 209, 248),
                      //     )),
                      // focusedBorder: OutlineInputBorder(
                      //   borderSide: const BorderSide(
                      //       color: Color.fromARGB(173, 125, 209, 248),
                      //       width: 1),
                      //   borderRadius: BorderRadius.circular(10),
                      // ),
                      // border: OutlineInputBorder(
                      //   borderSide: const BorderSide(
                      //       color: Color.fromARGB(173, 125, 209, 248),
                      //       width: 1),
                      //   borderRadius: BorderRadius.circular(10),
                      // ),
                    )),
              ),

              //       top: 10,
              //       child: Container(
              //         width: width - 210,
              //         decoration: BoxDecoration(
              //           color: kSignInContainerColor,
              //           borderRadius: BorderRadius.only(
              //             topRight: Radius.circular(15),
              //             bottomRight: Radius.circular(15),
              //           ),
              //         ),
              //         child: Padding(
              //           padding: const EdgeInsets.symmetric(vertical: 20),
              //           child: Text(
              //             "60% OFF ",
              //             style: TextStyle(
              //               fontWeight: FontWeight.w900,
              //               fontSize: 20,
              //               color: Colors.white,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),

              GestureDetector(
                onTap: () {
                  if (off.text == null) {
                  } else {
                    saveOffer();
                  }
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
                      "Post Offer ",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
