// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/profile/vendor_profile_screen.dart';
import 'package:nearbii/services/getOffers/getOffers.dart';
import 'package:nearbii/services/getcity.dart';
import 'package:swipe_refresh/swipe_refresh.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../Model/ServiceModel.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  late Position pos;
  bool isLoading = true;

  var selectedcat = "Category";
  @override
  void initState() {
    // TODO: implement initState
    FirebaseFirestore.instance
        .collection("User")
        .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
        .set({"offerNotif": false}, SetOptions(merge: true));
    refersh();
    super.initState();
  }

  swipe() {
    refersh();
  }

  void refersh() async {
    await load();
    await getCity();
    await getCat();
    await _getOffers(refersh: true);
  }

  load() async {
    Position poss = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (mounted) {
      setState(() {
        pos = poss;
        isLoading = false;
      });
    }
  }

  String city = "";
  getCity() async {
    getCat();
    city = await getcurrentCityFromLocation();
  }

  List<String> filter = ["Discount (High)", "Discount (Low)"];
  String applied = "Discount (High)";
  List<ServiceModel> cat = [];
  Future<void> getCat() async {
    cat = await Notifcheck.api.getServices();
  }

  var lastDocument;
  List<Widget> messageWidgets = [];
  _getOffers({bool refersh = false}) async {
    _controller.sink.add(SwipeRefreshState.loading);
    setState(() {});
    if (refersh) {
      messageWidgets = [];
      lastDocument = null;
      more = true;
    }
    log((applied == "Discount (High)" ? true : false).toString(),
        name: "discount");
    log((applied).toString(), name: "discount");
    var snap = FirebaseFirestore.instance.collection('Offers').orderBy("off",
        descending: applied == "Discount (High)" ? true : false);
    var _firestore = selectedcat == "Category"
        ? city != 'All India'
            ? snap.where("city", isEqualTo: city)
            : FirebaseFirestore.instance.collection('Offers')
        : snap
            .where("city", isEqualTo: city)
            .where("category", isEqualTo: selectedcat);
    List ndmta = [];
    if (lastDocument != null) {
      _firestore = _firestore.startAfterDocument(lastDocument);
    }
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore.limit(2).get();
    var dmta = snapshot.docs;
    if (snapshot.docs.isNotEmpty) {
      lastDocument = snapshot.docs.last;
      more = true;
    } else {
      more = false;
    }
    for (var ele in dmta) {
      Map deta = ele.data();

      var dis = Geolocator.distanceBetween(
            pos.latitude,
            pos.longitude,
            ele.data()["location"]["lat"],
            ele.data()["location"]["long"],
          ) /
          1000;
      deta.addEntries({"dis": dis.toDoubleStringAsFixed(digit: 3)}.entries);

      deta.addEntries({"ref": ele.reference}.entries);
      log(ele.reference.toString());
      ndmta.add(deta);
      log(deta.toString());
    }

    List<Widget> widgets = ndmta.map<Widget>((m) {
      final data = m as dynamic;
      var dis = 5;
      Timestamp ts = data['date'];
      DateTime dt =
          DateTime.fromMillisecondsSinceEpoch(ts.millisecondsSinceEpoch);
      final difference = DateTime.now().difference(dt).inSeconds;
      double limit = 86400;
      print(difference);
      if (difference <= limit) {
        return InkWell(
            onTap: () async {
              Future.delayed(const Duration(milliseconds: 5));
              await Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) {
                return VendorProfileScreen(
                  id: data["uid"],
                  isVisiter: true,
                );
              }));
            },
            child: offerBox(
              data: data,
            ));
      } else {
        m["ref"].delete();
      }

      return Container();
    }).toList();
    messageWidgets.addAll(widgets);
    _controller.sink.add(SwipeRefreshState.hidden);
    setState(() {});
  }

  final _controller = StreamController<SwipeRefreshState>.broadcast();

  Stream<SwipeRefreshState> get _stream => _controller.stream;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Offers label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Offers",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: kLoadingScreenTextColor,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: 20,
                  child: Center(
                    child: DropdownSearch<String>(
                      //mode of dropdown
                      //list of dropdown items
                      // ignore: prefer_const_constructors
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                          textAlignVertical: TextAlignVertical.center,
                          textAlign: TextAlign.end,
                          dropdownSearchDecoration: InputDecoration.collapsed(
                            hintText: 'City',
                          )),
                      items: CityList.ListCity.map((e) {
                        return e.name;
                      }).toList(),
                      onChanged: ((value) {
                        if (value == null) return;

                        city = value;
                        _getOffers(refersh: true);
                      }),
                      //show selected item\
                      selectedItem: city,
                    ),
                  ),
                ).expand(),
                SizedBox(
                  height: 20,
                  child: Center(
                    child: DropdownSearch<String>(
                        popupProps: PopupProps.menu(
                          constraints: BoxConstraints(maxHeight: 100),
                        ),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration:
                                InputDecoration.collapsed(hintText: 'City')),
                        selectedItem: applied,
                        items: filter.map((e) => e).toList(),
                        onChanged: ((value) {
                          if (value == null) return;
                          applied = value.toString();
                          _getOffers(refersh: true);
                        })),
                  ),
                ).expand(),
                SizedBox(
                  height: 20,
                  child: Center(
                    child: DropdownSearch<String>(
                        popupProps: PopupProps.menu(),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                            textAlignVertical: TextAlignVertical.center,
                            textAlign: TextAlign.end,
                            dropdownSearchDecoration: InputDecoration.collapsed(
                              hintText: 'City',
                            )),
                        selectedItem: selectedcat,
                        items: cat.map((e) => e.id).toList(),
                        onChanged: ((value) {
                          setState(() {
                            if (value == null) return;
                            selectedcat = value.toString();
                          });
                        })),
                  ),
                ).expand(),
              ],
            ).pOnly(bottom: 10, top: 10, left: 16, right: 0),
            NotificationListener<ScrollEndNotification>(
              onNotification: (scrollEnd) {
                final metrics = scrollEnd.metrics;
                if (metrics.atEdge) {
                  bool isTop = metrics.pixels == 0;
                  if (isTop) {
                    print('At the top');
                  } else {
                    print("botom");
                    _getOffers();
                  }
                }
                return true;
              },
              child: SwipeRefresh.builder(
                  itemCount: 1,
                  stateStream: _stream,
                  onRefresh: swipe,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemBuilder: (BuildContext context, int index) {
                    return !isLoading
                        ? getOffers(context, pos, city, applied, selectedcat)
                        : Container();
                  }),
            ),
          ],
        ).pOnly(top: 20),
      ),
    );
  }

  Widget getOffers(BuildContext context, Position pos, String city,
      String applied, String selectedcat) {
    var height = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        height: height - MediaQuery.of(context).size.height / 3.8,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ListView.separated(
            scrollDirection: Axis.vertical,
            itemCount: messageWidgets.length + 1,
            itemBuilder: (context, index) {
              if (messageWidgets.length < 2) more = false;
              return index < messageWidgets.length
                  ? messageWidgets[index]
                  : (more
                          ? CircularProgressIndicator()
                          : "No More Offers".text.make())
                      .centered()
                      .py8();
            },
            separatorBuilder: (context, index) => const SizedBox(
              width: 15,
            ),
          ),
        ),
      ),
    );
  }

  bool more = true;
}
