// ignore_for_file: prefer_const_constructors, unnecessary_null_comparison, prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/Model/vendormodel.dart';
import 'package:nearbii/components/search_bar.dart';
import 'package:nearbii/screens/bottom_bar/profile/vendor_profile_screen.dart';
import 'package:nearbii/services/getcity.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

class SearchVendor extends StatefulWidget {
  final String category;
  const SearchVendor(this.category, {Key? key}) : super(key: key);

  @override
  State<SearchVendor> createState() => _SearchVendorState();
}

class _SearchVendorState extends State<SearchVendor> {
  List<String> filter = ["Ratings", "Distance"];
  String applied = "Distance";

  QueryDocumentSnapshot<Map<String, dynamic>>? lastDocument;

  bool moreData = true;

  bool searching = false;

  @override
  void initState() {
    getCity();
    super.initState();
  }

  String city = "";
  getCity() async {
    city = await getcurrentCityFromLocation();

    pos ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (mounted) setState(() {});
    getVendors();
  }

  getVendors() async {
    String finalCity = city;
    Query<Map<String, dynamic>> snap =
        FirebaseFirestore.instance.collection("vendor");
    if (finalCity == "All India") {
      snap = FirebaseFirestore.instance.collection("vendor");
      if (widget.category.isEmptyOrNull) {
      } else {
        snap = snap.where("businessSubCat", isEqualTo: widget.category);
      }
    } else {
      snap = FirebaseFirestore.instance
          .collection("vendor")
          .where("businessCity", isEqualTo: finalCity);
      if (widget.category.isEmptyOrNull) {
      } else {
        snap = snap.where("businessSubCat", isEqualTo: widget.category);
      }
    }
    if (searchval.isNotEmptyAndNotNull) {
      snap = snap.where("caseSearch", arrayContains: searchval);
    }
    if (lastDocument != null) {
      snap = snap.startAfterDocument(lastDocument!);
    }
    QuerySnapshot<Map<String, dynamic>> snapshot = await snap.limit(5).get();
    print(snapshot.size);
    if (snapshot.size > 0) {
      moreData = true;
      setState(() {});
      lastDocument = snapshot.docs.last;
      for (var ele in snapshot.docs) {
        var vendor = VendorModel.fromMap(ele.data());
        // if ((vendor.businessCat
        //             .toString()
        //             .toLowerCase()
        //             .contains(searchval.toLowerCase()) ||
        //         vendor.businessAddress
        //             .toLowerCase()
        //             .contains(searchval.toLowerCase()) ||
        //         vendor.businessCity
        //             .toString()
        //             .toLowerCase()
        //             .contains(searchval.toLowerCase()) ||
        //         vendor.bussinesDesc
        //             .toString()
        //             .toLowerCase()
        //             .contains(searchval.toLowerCase()) ||
        //         vendor.businessName
        //             .toString()
        //             .toLowerCase()
        //             .contains(searchval.toLowerCase()) ||
        //         vendor.name
        //             .toString()
        //             .toLowerCase()
        //             .contains(searchval.toLowerCase()) ||
        //         vendor.businessSubCat
        //             .toString()
        //             .toLowerCase()
        //             .contains(searchval.toLowerCase())) &&
        //     vendor.active)
        {
          vendor.userId = ele.id;
          vendor.distance = Geolocator.distanceBetween(
              pos.latitude,
              pos.longitude,
              vendor.businessLocation.lat,
              vendor.businessLocation.long);

          vendor.book.value = false;
          var nowMin = DateTime.now().hour * 60 + DateTime.now().minute;
          var openMin =
              DateTime.fromMillisecondsSinceEpoch(vendor.openTime).hour * 60 +
                  DateTime.fromMillisecondsSinceEpoch(vendor.openTime).minute;
          var closeMin =
              DateTime.fromMillisecondsSinceEpoch(vendor.closeTime).hour * 60 +
                  DateTime.fromMillisecondsSinceEpoch(vendor.closeTime).minute;

          List<String> workday = vendor.workingDay.split("-");
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
              vendor.open = ("closed");
              vendor.active = false;
            } else {
              vendor.open = ("open");
            }
          } else {
            vendor.open = ("closed");
            vendor.active = false;
          }

          vendor.isAds = false;
          if (vendor.adsBuyTimestamp != null &&
              vendor.adsBuyTimestamp > DateTime.now().millisecondsSinceEpoch) {
            vendor.isAds = true;
          }
          if (vendor.active || true) vendorList.add(vendor);
        }
      }
      if (searchval.isNotEmptyAndNotNull) {
        await getBookmarkData();
      }
    } else {
      moreData = false;
      setState(() {});
    }
    if (mounted) {
      setState(() {
        searching = false;
      });
    }
  }

  sort() {
    if (applied == "Distance") {
      vendorList.sort((a, b) {
        return a.distance.compareTo(b.distance);
      });
    } else {
      vendorList.sort((a, b) {
        return b.rating.compareTo(a.rating);
      });
    }
    vendorList.sort((a, b) {
      if (b.isAds) {
        return 1;
      }
      return -1;
    });
    setState(() {});
  }

  int loading = 0;
  @override
  Widget build(BuildContext context) {
    var x = MediaQuery.of(context).size.width;
    var y = MediaQuery.of(context).size.height;

    return Material(
      child: Scaffold(
        body: SafeArea(
            child: Container(
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back)),
                ],
              ).pOnly(top: y / 32, left: y / 32, bottom: y / 32),
              SearchBar(
                search: search,
                // onTypeSearch: true,
                val: "",
              ).px16(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    height: 30,
                    child: Center(
                      child: DropdownSearch<String>(
                        //mode of dropdown
                        //list of dropdown items
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                        ),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                            textAlignVertical: TextAlignVertical.center,
                            textAlign: TextAlign.end,
                            dropdownSearchDecoration: InputDecoration.collapsed(
                                focusColor: Colors.lightBlue,
                                hintText: 'City')),
                        items: CityList.ListCity.map((e) {
                          return e.name;
                        }).toList(),
                        onChanged: ((value) {
                          if (value == null) return;
                          city = value;
                          lastDocument = null;
                          vendorList = [];
                          getVendors();
                        }),
                        //show selected item\
                        selectedItem: city,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    height: 30,
                    child: DropdownSearch<String>(
                        dropdownDecoratorProps: DropDownDecoratorProps(
                            textAlignVertical: TextAlignVertical.center,
                            textAlign: TextAlign.end,
                            dropdownSearchDecoration: InputDecoration.collapsed(
                                focusColor: Colors.lightBlue,
                                hintText: 'City')),
                        selectedItem: applied,
                        items: filter.map((e) => e).toList(),
                        onChanged: ((value) {
                          if (value == null) return;
                          applied = value.toString();
                          sort();
                        })),
                  )
                ],
              ).px16().pOnly(top: 8).pOnly(bottom: y / 32),
              result()
            ],
          ),
        )),
      ),
    );
  }

  List<VendorModel> vendorList = [];
  Widget result() {
    var x = MediaQuery.of(context).size.width;
    var y = MediaQuery.of(context).size.height;

    return city == ""
        ? Column(
            children: [
              CircularProgressIndicator(),
              5.heightBox,
              "Please wait,Getting your Location Info".text.makeCentered(),
            ],
          )
        : searching
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  "Searching for $searchval".text.make(),
                  5.widthBox,
                  CircularProgressIndicator()
                ],
              )
            : vendorList.isNotEmpty
                ? Expanded(
                    child: NotificationListener<ScrollEndNotification>(
                    onNotification: (scrollEnd) {
                      final metrics = scrollEnd.metrics;
                      if (metrics.atEdge) {
                        bool isTop = metrics.pixels == 0;
                        if (isTop) {
                          print('At the top');
                        } else {
                          getVendors();
                        }
                      }
                      return true;
                    },
                    child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 20),
                        itemBuilder: ((context, i) {
                          if (i < vendorList.length) {
                            var item = vendorList[i];
                            return ValueListenableBuilder(
                                valueListenable: item.visible,
                                builder: ((context, bool value, child) {
                                  return Row(
                                    children: [
                                      Image.network(
                                        item.businessImage.isEmptyOrNull
                                            ? Notifcheck.defCover
                                            : item.businessImage,
                                        width: x / 4,
                                        height: y / 6,
                                      ).p8(),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              item.businessName.text
                                                  .make()
                                                  .pOnly(right: 5),
                                              item.isAds
                                                  ? "Ad"
                                                      .text
                                                      .bold
                                                      .color(Color(0xff51B6C8))
                                                      .make()
                                                  : "".text.make(),
                                              Spacer(),
                                              ValueListenableBuilder(
                                                builder: (contex, value, c) {
                                                  return Icon(
                                                    item.book.value
                                                        ? Icons.bookmark
                                                        : Icons
                                                            .bookmark_outline,
                                                    color: Color(0xff51B6C8),
                                                  ).onInkTap(() async {
                                                    if (item.book.value) {
                                                      FirebaseFirestore.instance
                                                          .collection("User")
                                                          .doc(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid
                                                              .substring(0, 20))
                                                          .collection(
                                                              "bookmarks")
                                                          .doc(item.userId)
                                                          .delete()
                                                          .then((value) {
                                                        item.book.value = false;
                                                      });
                                                    } else {
                                                      FirebaseFirestore.instance
                                                          .collection("User")
                                                          .doc(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid
                                                              .substring(0, 20))
                                                          .collection(
                                                              "bookmarks")
                                                          .doc(item.userId)
                                                          .set({
                                                        item.userId.toString():
                                                            item.userId
                                                                .toString()
                                                      }).then((value) {
                                                        item.book.value = true;
                                                      });
                                                    }
                                                  });
                                                },
                                                valueListenable: item.book,
                                              )
                                            ],
                                          ).pOnly(top: 5, right: 10),
                                          Wrap(
                                            children: [
                                              RatingBar.builder(
                                                initialRating:
                                                    vendorList[i].rating,
                                                minRating: 1,
                                                ignoreGestures: true,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemSize: 20,
                                                itemBuilder: (context, _) =>
                                                    Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 1,
                                                ),
                                                onRatingUpdate: (rating) {},
                                              ),
                                              vendorList[i]
                                                  .rating
                                                  .toString()
                                                  .text
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
                                              Icon(
                                                Icons.location_on,
                                                color: Colors.grey,
                                              ),
                                              "${(item.distance / 1000).toDoubleStringAsPrecised(length: 2)} km"
                                                  .text
                                                  .color(Color.fromARGB(
                                                      96, 0, 0, 0))
                                                  .make()
                                                  .pOnly(right: 5),
                                              item.open
                                                  .toUpperCase()
                                                  .text
                                                  .bold
                                                  .color(Color(0xff51B6C8))
                                                  .make()
                                                  .pOnly(right: 5),
                                            ],
                                          ).pOnly(
                                              top: 5, right: 10, bottom: 10),
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
                                                        .color(
                                                            Color(0xff51B6C8))
                                                        .lg
                                                        .make()
                                                  ],
                                                ),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Color(0xff51B6C8))),
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
                                          }),
                                        ],
                                      ).expand(),
                                    ],
                                  ).onInkTap(() {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                VendorProfileScreen(
                                                  id: item.userId!,
                                                  isVisiter: true,
                                                )));
                                  });
                                }));
                          } else {
                            return moreData
                                ? CircularProgressIndicator().centered()
                                : "Opps !! No More Vendors"
                                    .text
                                    .make()
                                    .centered();
                          }
                        }),
                        separatorBuilder: ((context, i) {
                          return Divider(color: Color(0xff51B6C8));
                        }),
                        itemCount: vendorList.length + 1),
                  ))
                : "Nothing to Show".text.make();
  }

  var pos;
  String searchval = "";
  List<VendorModel> allVendorList = [];
  search(String val) {
    searchval = val;
    searching = true;
    if (searchval.isNotEmptyAndNotNull) {
      vendorList = [];
      lastDocument = null;
    }
    getVendors();
  }

  Future<void> getBookmarkData() async {
    // for (var item in vendorList) {
    //   var b = await FirebaseFirestore.instance
    //       .collection("User")
    //       .doc(item.userId)
    //       .get();
    //   if (b.data()!.containsKey('member')) {
    //     DateTime memDate =
    //         DateTime.fromMillisecondsSinceEpoch(b.data()!['member']["endDate"]);
    //     // DateTime endDate = memberData["endDate"].toDate();

    //     var now = DateTime.now();
    //     if (memDate.difference(now).inMilliseconds > 0 &&
    //         b.data()!['member']["isMember"]) {
    //       item.visible.value = true;
    //     } else {
    //       item.visible.value = false;
    //     }
    //   }

    //   var c = await FirebaseFirestore.instance
    //       .collection("User")
    //       .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
    //       .collection("bookmarks")
    //       .doc(item.userId)
    //       .get();

    //   if (c.exists) {
    //     item.book.value = true;
    //   }
    // }
  }
}
