// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:nearbii/screens/bottom_bar/event/viewEvent.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../constants.dart';

Widget getNearEvent(BuildContext context, String city, double height,
    ScrollController controller, pos) {
  try {
    final _firestore = FirebaseFirestore.instance;
    print("city is : " + city);
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Events')
          .where("city", isEqualTo: city)
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
        List messageWidgets = [];
        for (DocumentSnapshot m in snapshot.data!.docs) {
          // messageWidgets = snapshot.data!.docs.map((m)
          // {
          final data = m.data as dynamic;

          // Fluttertoast.showToast(
          //     msg: "Loc: " +
          //         data()["pinLocation"].toString().split(',').last.toString() +
          //         "City: " +
          //         city);

          {
            log(data()['eventLocation']["lat"].toString(), name: "event");
            var dis = Geolocator.distanceBetween(
                  pos.latitude,
                  pos.longitude,
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
              m.reference.delete();
            }
          }
          // else {
          //   return Padding(
          //     padding: const EdgeInsets.only(top: 150),
          //     child: Center(
          //       child: Container(
          //         height: 50,
          //         child: Text("No Nearby Events to show "),
          //       ),
          //     ),
          //   );
          // }
        }
        // ).toList();

        return messageWidgets.isNotEmpty
            ? Container(
                padding: EdgeInsets.only(top: 10),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListView.separated(
                    controller: controller,
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
              )
            : //   return Padding(
            Padding(
                padding: const EdgeInsets.only(top: 150),
                child: Center(
                  child: Container(
                    height: 50,
                    child: Text("No Nearby Events to show "),
                  ),
                ),
              );
      },
    );
  } catch (Ex) {
    print("0x1Error To Get User");
    return Container(
      child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(),
      ),
    );
  }
}

Widget eventBox(BuildContext context, String title, int startDate, String time,
    String addr, String img, double dis) {
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
