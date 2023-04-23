// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/Model/vendormodel.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/profile/vendor_profile_screen.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:url_launcher/url_launcher.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<VendorModel> bookmarks = [];
  bool show = true;
  @override
  void initState() {
    // TODO: implement initState
    getBookmarks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double y = MediaQuery.of(context).size.height;
    double x = MediaQuery.of(context).size.width;

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
      body: SafeArea(
          child: Column(
        children: [
          show == true
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : bookmarks.isEmpty
                  ? "Nothing to Show".text.makeCentered()
                  : ListView.separated(
                          itemBuilder: ((context, i) {
                            var item = bookmarks[i];
                            print('Time ${item.distance.toString()}');

                            var nowMin = DateTime.now().hour * 60 +
                                DateTime.now().minute;

                            var openMin = DateTime.fromMillisecondsSinceEpoch(
                                            item.openTime)
                                        .hour *
                                    60 +
                                DateTime.fromMillisecondsSinceEpoch(
                                        item.openTime)
                                    .minute;

                            var closeMin = DateTime.fromMillisecondsSinceEpoch(
                                            item.closeTime)
                                        .hour *
                                    60 +
                                DateTime.fromMillisecondsSinceEpoch(
                                        item.closeTime)
                                    .minute;

                            List<String> workday = item.workingDay.split("-");
                            Map<String, int> work = {
                              "mon": 1,
                              "tue": 2,
                              "wed": 3,
                              "thu": 4,
                              "fri": 5,
                              "sat": 6,
                              "sun": 7
                            };
                            int today = DateTime.now().weekday;
                            if (today >= work[workday.first.toLowerCase()]! &&
                                today <= work[workday.last.toLowerCase()]!) {
                              if (nowMin < openMin || nowMin > closeMin) {
                                item.open = ("closed");
                              } else {
                                item.open = ("open");
                              }
                            } else {
                              item.open = ("closed");
                            }

                            return SizedBox(
                              height: y / 6,
                              child: Row(
                                children: [
                                  SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Image.network(
                                              item.businessImage.isEmptyOrNull
                                                  ? Notifcheck.defCover
                                                  : item.businessImage)
                                          .p8()),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          item.businessName.text
                                              .make()
                                              .pOnly(right: 5),
                                          Spacer(),
                                          ValueListenableBuilder(
                                            builder: (contex, value, c) {
                                              return Icon(
                                                item.book.value
                                                    ? Icons.bookmark
                                                    : Icons.bookmark_outline,
                                                color: const Color(0xff51B6C8),
                                              ).onInkTap(() async {
                                                if (item.book.value) {
                                                  item.ref!.set({
                                                    "bookmarks":
                                                        FieldValue.arrayRemove([
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid
                                                          .substring(0, 20)
                                                    ])
                                                  }, SetOptions(merge: true));
                                                  FirebaseFirestore.instance
                                                      .collection("User")
                                                      .doc(FirebaseAuth.instance
                                                          .currentUser!.uid
                                                          .substring(0, 20))
                                                      .set(
                                                          {
                                                        "bookmarks": FieldValue
                                                            .arrayRemove([
                                                          item.userId.toString()
                                                        ])
                                                      },
                                                          SetOptions(
                                                              merge:
                                                                  true)).then(
                                                          (value) {
                                                    item.book.value = false;
                                                  });
                                                } else {
                                                  item.ref!.set({
                                                    "bookmarks":
                                                        FieldValue.arrayUnion([
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid
                                                          .substring(0, 20)
                                                    ])
                                                  }, SetOptions(merge: true));
                                                  FirebaseFirestore.instance
                                                      .collection("User")
                                                      .doc(FirebaseAuth.instance
                                                          .currentUser!.uid
                                                          .substring(0, 20))
                                                      .set(
                                                          {
                                                        "bookmarks": FieldValue
                                                            .arrayUnion([
                                                          item.userId.toString()
                                                        ])
                                                      },
                                                          SetOptions(
                                                              merge:
                                                                  true)).then(
                                                          (value) {
                                                    item.book.value = true;
                                                  });
                                                }
                                              });
                                            },
                                            valueListenable: item.book,
                                          )
                                        ],
                                      ).pOnly(top: 5, right: 10),
                                      Row(
                                        children: [
                                          item.rating.text
                                              .make()
                                              .pOnly(right: 5),
                                          RatingBar.builder(
                                            initialRating: 3,
                                            ignoreGestures: true,
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemSize: 20,
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 1,
                                            ),
                                            onRatingUpdate: (rating) {
                                              print(rating);
                                            },
                                          ),
                                          item.rating.text
                                              .make()
                                              .pOnly(left: 5, right: 1),
                                          "Ratings"
                                              .text
                                              .make()
                                              .pOnly(left: 5, right: 5),
                                        ],
                                      ).pOnly(top: 5, right: 10),
                                      Row(
                                        children: [
                                          "${(item.distance / 1000).toStringAsFixed(2)} km "
                                              .text
                                              .color(
                                                  Color.fromARGB(96, 0, 0, 0))
                                              .make(),
                                          Icon(Icons.location_on)
                                              .pOnly(right: 5),
                                          item.open
                                              .toUpperCase()
                                              .text
                                              .bold
                                              .color(Color(0xff51B6C8))
                                              .make()
                                              .pOnly(right: 5),
                                        ],
                                      ).pOnly(top: 5, right: 10, bottom: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: x / 2,
                                            height: y / 23,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.phone,
                                                  color: Color(0xff51B6C8),
                                                ),
                                                "Call Now "
                                                    .text
                                                    .color(Color(0xff51B6C8))
                                                    .lg
                                                    .make()
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Color(0xff51B6C8))),
                                          ),
                                        ],
                                      ).onInkTap(() async {
                                        var url =
                                            "tel:${item.businessMobileNumber}";
                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      })
                                    ],
                                  ).expand(),
                                ],
                              ),
                            ).onInkTap(() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VendorProfileScreen(
                                            id: item.userId!,
                                            isVisiter: true,
                                          )));
                            });
                          }),
                          separatorBuilder: ((context, i) {
                            return Divider(color: Color(0xff51B6C8));
                          }),
                          itemCount: bookmarks.length)
                      .px8()
                      .expand()
        ],
      )),
    );
  }

  var pos;

  getBookmarks() async {
    bookmarks = [];
    pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(FirebaseAuth.instance.currentUser!.uid);
    var b = await FirebaseFirestore.instance
        .collection("vendor")
        .where("bookmarks",
            arrayContains:
                FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
        .get();
    for (var elt in b.docs) {
      var vend = VendorModel.fromMap(elt.data());
      vend.ref = elt.reference;
      vend.userId = elt.id;
      vend.book.value = true;
      vend.distance = Geolocator.distanceBetween(vend.businessLocation.lat,
          vend.businessLocation.long, pos.latitude, pos.longitude);
      bookmarks.add(vend);
    }
    if (mounted) {
      setState(() {
        show = false;
      });
    }
  }
}
