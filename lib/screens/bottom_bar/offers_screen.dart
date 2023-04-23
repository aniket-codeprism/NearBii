// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
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

  var selectedcat = "All Category";

  var controller = ScrollController();
  @override
  void initState() {
    // TODO: implement initState

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

  List<String> filter = ["High", "Low", "Latest"];
  String applied = "High";
  List<ServiceModel> cat = [];
  Future<void> getCat() async {
    cat = await Notifcheck.api.getServices();
    cat.insert(
        0,
        ServiceModel(
            id: "All Category",
            image: "image",
            subcategory: [],
            isActive: true,
            order: 0));
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
    log((applied == "High" ? true : false).toString(), name: "discount");
    log((applied).toString(), name: "discount");
    Query<Map<String, dynamic>> snap =
        FirebaseFirestore.instance.collection('Offers');
    switch (applied) {
      case "High":
        snap = snap.orderBy("off", descending: true);
        break;
      case "Latest":
        snap = snap.orderBy("date", descending: true);
        break;
      case "Low":
        snap = snap.orderBy("off", descending: false);
        break;
    }
    if (city != 'All India') {
      snap = snap.where("city", isEqualTo: city);
    }
    if (selectedcat != "All Category") {
      snap = snap.where("category", isEqualTo: selectedcat);
    }

    List ndmta = [];
    if (lastDocument != null) {
      snap = snap.startAfterDocument(lastDocument);
    }
    QuerySnapshot<Map<String, dynamic>> snapshot = await snap.limit(2).get();
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
      var ts = data['date'];
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(ts);
      final difference = DateTime.now().difference(dt).inMinutes;
      double limit = 43800;
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
    return SafeArea(
      child: Scaffold(
        body: NotificationListener<ScrollEndNotification>(
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
              scrollController: controller,
              itemCount: 1,
              stateStream: _stream,
              onRefresh: swipe,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemBuilder: (BuildContext context, int index) {
                return SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      //Offers label
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 30,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color:
                                            Color.fromARGB(255, 81, 182, 200))),
                                child: Center(
                                  child: DropdownSearch<String>(
                                    dropdownButtonProps: DropdownButtonProps(
                                      padding: EdgeInsets.all(0),
                                    ),
                                    //mode of dropdown
                                    //list of dropdown items
                                    popupProps: PopupProps.bottomSheet(
                                      title: Divider(
                                        height: 10,
                                        thickness: 2,
                                        color:
                                            Color.fromARGB(255, 81, 182, 200),
                                      ).px(128).py2(),
                                      interceptCallBacks: true,
                                      showSelectedItems: true,
                                      searchDelay: Duration.zero,
                                      searchFieldProps: TextFieldProps(
                                        decoration: InputDecoration(
                                            icon: Icon(Icons.search),
                                            hintText: "Search City",
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20))),
                                      ),
                                      bottomSheetProps: BottomSheetProps(
                                          backgroundColor: Color.fromARGB(
                                              255, 232, 244, 247),
                                          elevation: 10,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20))),
                                      showSearchBox: true,
                                    ),
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
                                            baseStyle:
                                                TextStyle(
                                                    overflow: TextOverflow
                                                        .ellipsis),
                                            textAlignVertical: TextAlignVertical
                                                .center,
                                            textAlign: TextAlign.center,
                                            dropdownSearchDecoration:
                                                InputDecoration.collapsed(
                                                    floatingLabelAlignment:
                                                        FloatingLabelAlignment
                                                            .center,
                                                    floatingLabelBehavior:
                                                        FloatingLabelBehavior
                                                            .auto,
                                                    focusColor:
                                                        Colors.lightBlue,
                                                    hintText: 'City')),
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
                              ),
                            ],
                          ).px4().expand(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 30,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color:
                                            Color.fromARGB(255, 81, 182, 200))),
                                child: Center(
                                  child: DropdownSearch<String>(
                                      dropdownButtonProps: DropdownButtonProps(
                                        padding: EdgeInsets.all(0),
                                      ),
                                      popupProps: PopupProps.menu(
                                        fit: FlexFit.loose,
                                      ),
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                              baseStyle:
                                                  TextStyle(
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                              textAlignVertical:
                                                  TextAlignVertical.center,
                                              textAlign: TextAlign.center,
                                              dropdownSearchDecoration:
                                                  InputDecoration.collapsed(
                                                      floatingLabelAlignment:
                                                          FloatingLabelAlignment
                                                              .center,
                                                      floatingLabelBehavior:
                                                          FloatingLabelBehavior
                                                              .auto,
                                                      focusColor:
                                                          Colors.lightBlue,
                                                      hintText: 'City')),
                                      selectedItem: applied,
                                      items: filter.map((e) => e).toList(),
                                      onChanged: ((value) {
                                        if (value == null) return;
                                        applied = value.toString();

                                        _getOffers(refersh: true);
                                      })),
                                ),
                              ),
                            ],
                          ).px4().expand(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 30,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color:
                                            Color.fromARGB(255, 81, 182, 200))),
                                child: Center(
                                  child: DropdownSearch<String>(
                                      dropdownButtonProps: DropdownButtonProps(
                                        padding: EdgeInsets.all(0),
                                      ),
                                      //mode of dropdown
                                      //list of dropdown items
                                      popupProps: PopupProps.bottomSheet(
                                        title: Divider(
                                          height: 10,
                                          thickness: 2,
                                          color:
                                              Color.fromARGB(255, 81, 182, 200),
                                        ).px(128).py2(),
                                        interceptCallBacks: true,
                                        showSelectedItems: true,
                                        searchDelay: Duration.zero,
                                        searchFieldProps: TextFieldProps(
                                          decoration: InputDecoration(
                                              icon: Icon(Icons.search),
                                              hintText: "Search Category",
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20))),
                                        ),
                                        bottomSheetProps: BottomSheetProps(
                                            backgroundColor: Color.fromARGB(
                                                255, 232, 244, 247),
                                            elevation: 10,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20))),
                                        showSearchBox: true,
                                      ),
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                              baseStyle:
                                                  TextStyle(
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                              textAlignVertical:
                                                  TextAlignVertical.center,
                                              textAlign: TextAlign.center,
                                              dropdownSearchDecoration:
                                                  InputDecoration.collapsed(
                                                      floatingLabelAlignment:
                                                          FloatingLabelAlignment
                                                              .center,
                                                      floatingLabelBehavior:
                                                          FloatingLabelBehavior
                                                              .auto,
                                                      focusColor:
                                                          Colors.lightBlue,
                                                      hintText: 'City')),
                                      selectedItem: selectedcat,
                                      items: cat.map((e) => e.id).toList(),
                                      onChanged: ((value) {
                                        if (value == null) return;
                                        selectedcat = value.toString();

                                        _getOffers(refersh: true);
                                      })),
                                ),
                              ),
                            ],
                          ).px4().expand(),
                        ],
                      ).pOnly(bottom: 10, top: 10, left: 16, right: 0),

                      !isLoading
                          ? getOffers(context, pos, city, applied, selectedcat)
                          : Container(),
                    ],
                  ).pOnly(top: 20),
                );
              }),
        ),
      ),
    );
  }

  Widget getOffers(BuildContext context, Position pos, String city,
      String applied, String selectedcat) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 10),
          child: SizedBox(
            child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListView.separated(
                  controller: controller,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
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
                    height: 15,
                  ),
                )),
          ),
        ),
      ],
    );
  }

  bool more = true;
}
