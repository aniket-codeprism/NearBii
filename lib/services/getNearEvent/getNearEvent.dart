// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:nearbii/screens/bottom_bar/event/viewEvent.dart';

import '../../constants.dart';

class getNearEvent extends StatefulWidget {
  final String city;
  final double height;
  final ScrollController controller;
  final pos;
  const getNearEvent(
      {Key? key,
      required this.city,
      required this.height,
      required this.controller,
      required this.pos})
      : super(key: key);

  @override
  State<getNearEvent> createState() => _getNearEventState();
}

class _getNearEventState extends State<getNearEvent> {
  @override
  Widget build(BuildContext context) {
    return messageWidgets.isNotEmpty
        ? Container(
            padding: EdgeInsets.only(top: 10),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: NotificationListener<ScrollEndNotification>(
                onNotification: (scrollEnd) {
                  final metrics = scrollEnd.metrics;
                  if (metrics.atEdge) {
                    bool isTop = metrics.pixels == 0;
                    if (isTop) {
                      print('At the top');
                    } else {
                      getEventsFromCity(city: widget.city);
                    }
                  }
                  return true;
                },
                child: ListView.separated(
                  controller: widget.controller,
                  shrinkWrap: true,
                  itemCount: messageWidgets.length,
                  itemBuilder: (context, index) {
                    return messageWidgets[index] ?? SizedBox();
                  },
                  separatorBuilder: (context, index) => SizedBox(
                    width: 15,
                  ),
                ),
              ),
            ),
          )
        : //   return Padding(
        Padding(
            padding: const EdgeInsets.only(top: 150),
            child: Center(
              child: SizedBox(
                height: 50,
                child: Text("No Nearby Events to show "),
              ),
            ),
          );
  }

  Widget eventBox(BuildContext context, String title, int startDate,
      String time, String addr, String img, double dis) {
    return Container(
      padding: EdgeInsets.only(top: 25),
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                    Row(
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
                                DateTime.fromMillisecondsSinceEpoch(startDate)),
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
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 20,
                          color: kDividerColor,
                        ),
                        Text(
                          addr,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: kDividerColor,
                          ),
                        ).scrollHorizontal().px(6),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.social_distance,
                          color: Colors.grey,
                          size: 15,
                        ),
                        (dis.toStringAsPrecision(3) + " Km")
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
              Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
                child: Image.network(
                  img,
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  var lastDocument;
  bool moreData = true;
  List<Widget> messageWidgets = [];
  void getEventsFromCity({required String city}) async {
    final _firestore = FirebaseFirestore.instance;
    Query<Map<String, dynamic>> snap =
        _firestore.collection('Events').where("city", isEqualTo: city);
    if (lastDocument != null) {
      snap = snap.startAfterDocument(lastDocument!);
    }
    QuerySnapshot<Map<String, dynamic>> snapshot = await snap.limit(5).get();
    print(snapshot.size);
    if (snapshot.size > 0) {
      lastDocument = snapshot.docs.last;
      for (var ele in snapshot.docs) {
        moreData = true;
        // messageWidgets = snapshot.data!.docs.map((m)
        // {
        final data = ele.data as dynamic;

        // Fluttertoast.showToast(
        //     msg: "Loc: " +
        //         data()["pinLocation"].toString().split(',').last.toString() +
        //         "City: " +
        //         city);

        {
          log(data()['eventLocation']["lat"].toString(), name: "event");
          var dis = Geolocator.distanceBetween(
                widget.pos.latitude,
                widget.pos.longitude,
                data()["eventLocation"]["lat"],
                data()["eventLocation"]["long"],
              ) /
              1000;
          DateTime dt =
              DateTime.fromMillisecondsSinceEpoch(data()['eventEndData']);
          print(dt);

          final difference = dt.difference(DateTime.now()).inSeconds;
          print(difference);
          if (difference >= 0) {
            messageWidgets.add(InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return ViewEvent(
                      data: data,
                      dis: dis,
                    );
                  }));
                },
                child: eventBox(
                    context,
                    data()["name"],
                    data()["eventStartDate"],
                    data()["eventTime"],
                    data()["addr"],
                    data()["eventImage"][0],
                    dis)));
          } else {
            print("time over");
            ele.reference.delete();
          }
        }
      }
    } else {
      moreData = false;
    }
    if (mounted) {
      setState(() {});
    }
  }
}
