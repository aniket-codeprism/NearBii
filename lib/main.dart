// ignore_for_file: prefer_const_constructors, unused_import, unused_element

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:nearbii/Model/vendormodel.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/createEvent/addEvent/addEvent.dart';
import 'package:nearbii/screens/loading_screen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/annual_plan/business_service_details_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  // description
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  SharedPreferences session = await SharedPreferences.getInstance();
  Map valueMap = json.decode(session.getString("LastLocation")!);
  String? city = session.getString("userLocation");

  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null) {
    if (message.data["type"].toString() == "event" &&
        message.data["type"].toString() == city) {
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
      double distance = Geolocator.distanceBetween(
        valueMap["lat"],
        valueMap["long"],
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

        String notiftype = message.data["type"].toString() == "event"
            ? "eventNotif"
            : "offerNotif";
        FirebaseFirestore.instance
            .collection("User")
            .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
            .set({notiftype: true}, SetOptions(merge: true));
      }
    } else {
      var c = BusinessLocation.fromJson(message.data["location"]!);

      double distance = Geolocator.distanceBetween(
        valueMap["lat"],
        valueMap["long"],
        c.lat,
        c.long,
      );
      if (distance < 5000) {
        FirebaseFirestore.instance
            .collection("User")
            .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
            .collection("Notifs")
            .doc("notifsIDs")
            .update({
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
                .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
                .set({"newNotif": true}, SetOptions(merge: true)));
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationPermissions.requestNotificationPermissions();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const NearBii());
}

class NearBii extends StatelessWidget {
  const NearBii({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    bool _allow = true;
    return MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          MonthYearPickerLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        title: 'NearBii',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          appBarTheme: AppBarTheme(
            elevation: 0.0,
            backgroundColor: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.white,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            elevation: 0,
            selectedIconTheme: IconThemeData(color: Colors.black),
            unselectedIconTheme: IconThemeData(color: kWalletLightTextColor),
            selectedLabelStyle: TextStyle(color: Colors.black),
            unselectedLabelStyle: TextStyle(color: kWalletLightTextColor),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Material(
          child: WillPopScope(
              onWillPop: () {
                return Future.value(_allow);
              },
              child: LoadingScreen()),
        ));
  }
}
