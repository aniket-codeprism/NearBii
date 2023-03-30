import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/Model/vendormodel.dart';
import 'package:nearbii/main.dart';
import 'package:nearbii/screens/bottom_bar/event/event_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/home_screen.dart';
import 'package:nearbii/screens/bottom_bar/offers_screen.dart';
import 'package:nearbii/screens/bottom_bar/profile/profile_screen.dart';
import 'package:nearbii/screens/bottom_bar/scan_screen.dart';
import 'package:nearbii/services/sendNotification/registerToken/registerTopicNotificaion.dart';
import 'package:nearbii/services/setUserMode.dart';

class MasterPage extends StatefulWidget {
  final int currentIndex;
  const MasterPage({Key? key, required this.currentIndex}) : super(key: key);

  @override
  _MasterPageState createState() => _MasterPageState();
}

class _MasterPageState extends State<MasterPage> {
  int selectedIndex = 0;
  final firestore = FirebaseFirestore.instance;

  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);
  loadUser() async {
    bool user = await Notifcheck.api.isUser();
    if (!user) {
      var b =
          await FirebaseFirestore.instance.collection('vendor').doc(uid).get();
      if (b.data() != null) {
        Notifcheck.currentVendor = VendorModel.fromMap(b.data()!);
      }
    }
  }

  getcity() async {
    await CityList.getCities();
    setState(() {});
  }

  @override
  void initState() {
    getcity();
    loadUser();
    subscribeTopicCity();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      log(android.toString(), name: "notifications");
      log(notification.toString(), name: "notifications");
      if (notification != null && android != null) {
        if (message.data["type"].toString() == "event") {
          flutterLocalNotificationsPlugin.show(
            message.hashCode,
            message.notification!.title,
            "Posted an Event",
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
              ),
            ),
          );
          FirebaseFirestore.instance
              .collection("User")
              .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
              .set({"eventNotif": true}, SetOptions(merge: true));
        } else if (message.data["type"].toString() == "offer") {
          var c = BusinessLocation.fromJson(message.data["pin"]!);

          log(c.toString(), name: "notifications");
          var pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          double distance = Geolocator.distanceBetween(
            pos.latitude,
            pos.longitude,
            c.lat,
            c.long,
          );
          if (distance < 5000) {
            flutterLocalNotificationsPlugin.show(
              message.hashCode,
              message.notification!.title,
              message.data["title"],
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channelDescription: channel.description,
                  color: Colors.blue,
                  playSound: true,
                ),
              ),
            );
            log(message.data["type"], name: "notifications");
            String notiftype = message.data["type"].toString() == "event"
                ? "eventNotif"
                : "offerNotif";
            FirebaseFirestore.instance
                .collection("User")
                .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
                .set({notiftype: true}, SetOptions(merge: true));
          }
        } else if (message.data["type"].toString() == "wallet") {
          flutterLocalNotificationsPlugin.show(
            message.hashCode,
            message.notification!.title,
            "${message.data["amount"]} points",
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
              ),
            ),
          );
        } else {
          var c = BusinessLocation.fromJson(message.data["location"]!);

          log(c.toString(), name: "notifications");

          await Geolocator.checkPermission();
          await Geolocator.requestPermission();
          var pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          double distance = Geolocator.distanceBetween(
            pos.latitude,
            pos.longitude,
            c.lat,
            c.long,
          );
          if (distance < 5000) {
            FirebaseFirestore.instance
                .collection("User")
                .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
                .collection("Notifs")
                .doc("notifsIDs")
                .set({
              "id": FieldValue.arrayUnion([
                {
                  "id": "22",
                  "isOffer": message.data["type"],
                  "uid": message.data["vendorUID"],
                  "name": message.notification!.title,
                  "image": message.data["image"],
                  "time": DateTime.now().millisecondsSinceEpoch
                }
              ])
            }).whenComplete(() => FirebaseFirestore.instance
                    .collection("User")
                    .doc(
                        FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
                    .set({"newNotif": true}, SetOptions(merge: true)));
          }
        }
      }
    });

    FirebaseFirestore.instance
        .collection("User")
        .doc(uid)
        .snapshots()
        .listen((value) {
      if (value.data() != null) {
        if (value.data()!.containsKey("newNotif")) {
          Notifcheck.bell.value = value.data()!["newNotif"];
        }
        if (value.data()!.containsKey("eventNotif")) {
          Notifcheck.event.value = value.data()!["eventNotif"];
        }
        if (value.data()!.containsKey("offerNotif")) {
          Notifcheck.offer.value = value.data()!["offerNotif"];
        }
        if (value.data()!.containsKey("type")) {
          value.data()!["type"] == "User" ? setUserMode() : setVendorMode();
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const EventScreen(),
      const OffersScreen(),
      const ScanScreen(),
      const ProfileScreen(),
    ];
    return WillPopScope(
      onWillPop: () async {
        if (selectedIndex == 0) return true;
        selectedIndex = 0;
        setState(() {});
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: ValueListenableBuilder(
                builder: (context, bool value, Widget? child) {
                  return Icon(
                    Icons.event_note_outlined,
                    color: Notifcheck.event.value ? Colors.amber : Colors.grey,
                  );
                },
                valueListenable: Notifcheck.event,
              ),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: ValueListenableBuilder(
                builder: (context, bool value, Widget? child) {
                  return Icon(
                    Icons.local_offer_outlined,
                    color: Notifcheck.offer.value ? Colors.amber : Colors.grey,
                  );
                },
                valueListenable: Notifcheck.offer,
              ),
              label: 'Offers',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_outlined),
              label: 'Scan',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_outlined),
              label: 'Profile',
            ),
          ],
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
