import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nearbii/Model/cityModel.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/components/search_bar.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/services/getcity.dart';
import 'package:velocity_x/velocity_x.dart';

import '../viewEvent.dart';

class AllNearbyEventsScreen extends StatefulWidget {
  const AllNearbyEventsScreen({Key? key}) : super(key: key);

  @override
  State<AllNearbyEventsScreen> createState() => _AllNearbyEventsScreenState();
}

class _AllNearbyEventsScreenState extends State<AllNearbyEventsScreen> {
  String query = '';
  var pos;
  List<Cities> citites = [];

  var lastDocument;
  @override
  void initState() {
    super.initState();
    citites = CityList.ListCity;
    getCity();
  }

  String city = "";
  getCity() async {
    city = await getcurrentCityFromLocation();
    pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    await getAllEvents();
    if (mounted) setState(() {});
  }

  var catList = [];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (scrollEnd) {
              final metrics = scrollEnd.metrics;
              if (metrics.atEdge) {
                bool isTop = metrics.pixels == 0;
                if (isTop) {
                  print('At the top');
                } else {
                  getAllEvents();
                }
              }
              return true;
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      "All Events",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: kLoadingScreenTextColor,
                      ),
                    ),
                  ),
                  //search box
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      // decoration: BoxDecoration(
                      //   border: Border.all(color: kCircleBorderColor),
                      //   borderRadius: BorderRadius.circular(5),
                      // ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: SearchBar(
                            search: (quer) {
                              print(quer);
                              messageWidgets = [];
                              lastDocument = null;
                              query = quer.toString().toLowerCase();
                              getAllEvents();
                            },
                            val: '',
                          )),
                    ),
                  ),

                  DropdownSearch<String>(
                    //mode of dropdown
                    //list of dropdown items
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                    ),
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                      labelText: "City",
                    )),
                    items: citites.map((e) {
                      return e.name;
                    }).toList(),
                    onChanged: ((value) {
                      if (value == null) return;
                      city = value;
                      print(city);
                      lastDocument = null;
                      messageWidgets = [];
                      getAllEvents();
                    }),
                    //show selected item
                    selectedItem: city,
                  ).px16(),
                  if (messageWidgets.isEmpty && query.isNotEmptyAndNotNull)
                    const CircularProgressIndicator().centered()
                  else
                    city.isNotEmptyAndNotNull
                        ? ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: messageWidgets.length + 1,
                            shrinkWrap: true,
                            itemBuilder: (context, i) {
                              if (messageWidgets.length < 5) {
                                moreData = false;
                              }
                              if (i < messageWidgets.length) {
                                return messageWidgets[i];
                              } else {
                                return (moreData
                                        ? const CircularProgressIndicator()
                                            .centered()
                                        : "Opps !! No More Events"
                                            .text
                                            .make()
                                            .centered())
                                    .py8();
                              }
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                              width: 15,
                            ),
                          )
                        : Column(
                            children: [
                              const CircularProgressIndicator(),
                              5.heightBox,
                              "Please wait,Getting your Location Info"
                                  .text
                                  .makeCentered(),
                            ],
                          ).py8(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> messageWidgets = [];

  Widget eventBox(context, String title, int startDate, String time,
      String addr, String img, double dis) {
    return Container(
      padding: const EdgeInsets.only(top: 25),
      child: Material(
        elevation: 1,
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.80,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: kLoadingScreenTextColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 11),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 15,
                            color: kDividerColor,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 6),
                            child: Text(
                              DateFormat("dd-MM-yyyy").format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      startDate)),
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: kDividerColor,
                              ),
                            ),
                          ),
                          Text(
                            time,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: kSignInContainerColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 20,
                          color: kDividerColor,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          addr,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: kDividerColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.social_distance,
                          color: Colors.grey,
                          size: 15,
                        ),
                        (dis.toStringAsFixed(2) + " Km")
                            .text
                            .color(Colors.grey)
                            .make()
                            .px4()
                            .px(6),
                      ],
                    )
                  ],
                ),
              ),
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.only(right: 10),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
                child: Image.network(
                  img,
                  fit: BoxFit.fill,
                ),
                // child: InteractiveViewer(
                //   boundaryMargin: const EdgeInsets.all(20.0),
                //   minScale: 1.0,
                //   maxScale: 1.0,
                //   child:
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool moreData = true;
  getAllEvents() async {
    Query<Map<String, dynamic>> snap;
    if (city != "All India") {
      snap = FirebaseFirestore.instance
          .collection('Events')
          .where("eventTargetCity", isEqualTo: city);
    } else {
      snap = FirebaseFirestore.instance.collection('Events');
    }
    if (lastDocument != null) {
      snap = snap.startAfterDocument(lastDocument!);
    }
    if (query.isNotEmptyAndNotNull) {
      snap = snap.where("caseSearch", arrayContains: query);
    }
    QuerySnapshot<Map<String, dynamic>> snapshot = await snap.limit(5).get();
    if (snapshot.size > 0) {
      moreData = true;
      setState(() {});
      lastDocument = snapshot.docs.last;
      List<Widget> widgets = snapshot.docs.map<Widget>((m) {
        final data = m.data as dynamic;
        if (DateTime.now().millisecondsSinceEpoch > data()["eventEndData"]) {
          m.reference.delete();
        }

        var dis = Geolocator.distanceBetween(
              pos.latitude,
              pos.longitude,
              data()["eventLocation"]["lat"],
              data()["eventLocation"]["long"],
            ) /
            1000;
        log(dis.toString());
        return InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return ViewEvent(data: data, dis: dis);
            }));
          },
          child: eventBox(
              context,
              data()["name"],
              data()["eventStartDate"],
              data()["eventTime"],
              data()["city"],
              data()["eventImage"][0],
              dis),
        );
      }).toList();
      messageWidgets.addAll(widgets);
    } else {
      moreData = false;
    }
    setState(() {});
  }
}
