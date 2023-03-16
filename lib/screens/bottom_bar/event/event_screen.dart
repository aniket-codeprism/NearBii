// ignore_for_file: unused_local_variable, avoid_print, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/event/all_events_screen.dart';
import 'package:nearbii/screens/bottom_bar/event/all_nearby_events/all_nearby_events_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearbii/screens/bottom_bar/event/eventByDate/eventByDate.dart';
import 'package:nearbii/services/getEventCat/eventCat.dart';
import 'package:nearbii/services/getNearEvent/getNearEvent.dart';
import 'package:nearbii/services/getcity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  int selectedIndex = 0;
  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final events = ['Concert', 'Art', 'Sports', 'Education', 'Food'];
  final eventIcons = [
    Image.asset('assets/images/events/concert.png'),
    Image.asset('assets/images/events/arts.png'),
    Image.asset('assets/images/events/sports.png'),
    Image.asset('assets/images/events/education.png'),
    Image.asset('assets/images/events/food.png'),
  ];

  int dateStartIndex = 0;
  int dateWeekDay = 0;

  List<int> weekDateList = [];
  List<String> weekDayList = [];
  List<DateTime> weekFullDate = [];

  String userLocation = "";

  var controller = new ScrollController();
  var pos;
  @override
  void initState() {
    super.initState();
    getLocation();

    FirebaseFirestore.instance
        .collection("User")
        .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
        .set({"eventNotif": false}, SetOptions(merge: true));
    getDates();
  }

  Future<void> getLocation() async {
    userLocation = await getcurrentCityFromLocation();
    pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (this.mounted) setState(() {});
  }

  void getDates() {
    final _currentDate = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, 0, 0, 0, 0, 0);
    final _dayFormatter = DateFormat('d');
    final _monthFormatter = DateFormat('MMM');

    for (int i = 0; i < 7; i++) {
      final date =
          _currentDate.add(Duration(days: i, hours: 0, minutes: 0, seconds: 0));

      weekDayList.add(days[(date.weekday) - 1]);
      weekDateList.add(date.day);
      weekFullDate.add(date);

      print(weekDayList);
      print(weekDateList);
    }
  }

  makeDateList() {}

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Events label
                Text(
                  "Events",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: kLoadingScreenTextColor,
                  ),
                ),
                //dates
                SizedBox(
                  height: 112,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: weekDateList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;

                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return allEventByDate(
                                    date: weekFullDate[index]);
                              }));
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedIndex == index
                                  ? kSignInContainerColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 9, horizontal: 7),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    weekDayList[index].toString(),
                                    style: TextStyle(
                                      fontWeight: selectedIndex == index
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      fontSize: 18,
                                      color: selectedIndex == index
                                          ? Colors.white
                                          : kLoadingScreenTextColor,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    weekDateList[index].toString(),
                                    style: TextStyle(
                                      fontWeight: selectedIndex == index
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      fontSize: 18,
                                      color: selectedIndex == index
                                          ? Colors.white
                                          : kLoadingScreenTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(
                        width: 10,
                      ),
                    ),
                  ),
                ),
                //Divider
                Container(
                  color: kDrawerDividerColor,
                  height: 0.5,
                  width: double.infinity,
                ),
                //All Events label
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 19),
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      "All Events",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: kLoadingScreenTextColor,
                      ),
                    ),
                  ),
                ),
                //all events
                getEventCatList(context, pos, userLocation),
                Row(
                  children: [
                    Text(
                      "Events Nearby",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: kLoadingScreenTextColor,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AllNearbyEventsScreen(),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "See All",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: kLoadingScreenTextColor,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: kLoadingScreenTextColor,
                            size: 13,
                          )
                        ],
                      ),
                    ),
                  ],
                ),

                if (pos != null)
                  getNearEvent(context, userLocation, height, controller, pos),
              ],
            ),
          ).pOnly(top: 20),
        ),
      ),
    );
  }
}
