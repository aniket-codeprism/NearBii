import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:nearbii/Model/notifStorage.dart';

sendNotiicationByCity(String title, String city, String id, String type) async {
  const postUrl = 'https://fcm.googleapis.com/fcm/send';
  const token =
      'AAAACt0GUvs:APA91bGNgTvPF7QExy-2kgfQlC2ghq1MwC4n2mq4EAgwc1NJtXghvhsQN63_xLaUP3SfHiSVyev3VTbyFwJRV9_gVhmjhKoyo-LmfF_Zat7nDKDHTS4SdCm98aEq9tb2WHPLVI8C4cES';
  String toParams = "/topics/city_" + city;

  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);

  final data = {
    "notification": {
      "body": "New Event In Your City By $title",
      "title": title
    },
    "priority": "high",
    "data": {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "title": title,
      "city": city,
      "vendorUID": uid,
      "type": type,
      "evenId": id
    },
    "to": toParams
  };

  final headers = {
    'content-type': 'application/json',
    'Authorization': 'key=' + token
  };

  final response = await http.post(Uri.parse(postUrl),
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
      headers: headers);

  if (response.statusCode == 200) {
// on success do
    Fluttertoast.showToast(msg: "Notification Sent to tageted city");
  } else {
// on failure do
    Fluttertoast.showToast(msg: "Notification Not Sent");
  }
}

sendNotiicationByPin(String title, String id, String type, String name) async {
  const postUrl = 'https://fcm.googleapis.com/fcm/send';
  const token =
      'AAAACt0GUvs:APA91bGNgTvPF7QExy-2kgfQlC2ghq1MwC4n2mq4EAgwc1NJtXghvhsQN63_xLaUP3SfHiSVyev3VTbyFwJRV9_gVhmjhKoyo-LmfF_Zat7nDKDHTS4SdCm98aEq9tb2WHPLVI8C4cES';
  String toParams = "/topics/Offer";

  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);

  final data = {
    "notification": {"body": "New Offer By " + name, "title": title},
    "priority": "high",
    "data": {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "title": "New Offer By " + name,
      "pin": Notifcheck.currentVendor!.businessLocation.toJson(),
      "vendorUID": uid,
      "type": type,
      "evenId": id
    },
    "to": toParams
  };

  final headers = {
    'content-type': 'application/json',
    'Authorization': 'key=' + token
  };

  final response = await http.post(Uri.parse(postUrl),
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
      headers: headers);

  if (response.statusCode == 200) {
// on success do
    Fluttertoast.showToast(msg: "Notification Sent to tageted city");
  } else {
// on failure do
    Fluttertoast.showToast(msg: "Notification Not Sent");
  }
}

sendNotiicationAd(String title, String image) async {
  log("message", name: "notifications");

  const postUrl = 'https://fcm.googleapis.com/fcm/send';
  const token =
      'AAAACt0GUvs:APA91bGNgTvPF7QExy-2kgfQlC2ghq1MwC4n2mq4EAgwc1NJtXghvhsQN63_xLaUP3SfHiSVyev3VTbyFwJRV9_gVhmjhKoyo-LmfF_Zat7nDKDHTS4SdCm98aEq9tb2WHPLVI8C4cES';
  String toParams = "/topics/city_".toString() + "ADS";

  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);
  final data = {
    "notification": {"body": "New Event in Your City", "title": title},
    "priority": "high",
    "data": {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "title": title,
      "location": Notifcheck.currentVendor!.businessLocation.toJson(),
      "vendorUID": uid,
      "type": "ad",
      "image": image
    },
    "to": toParams
  };

  final headers = {
    'content-type': 'application/json',
    'Authorization': 'key=' + token
  };

  final response = await http.post(Uri.parse(postUrl),
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
      headers: headers);

  if (response.statusCode == 200) {
// on success do
    Fluttertoast.showToast(msg: "AD posted Successfull");
  } else {
// on failure do
    Fluttertoast.showToast(msg: "AD posted Successfull");
  }
}

sendNotificationWallet(String uidd, double amount, String s) async {
  log("message", name: "notifications");

  const postUrl = 'https://fcm.googleapis.com/fcm/send';
  const token =
      'AAAACt0GUvs:APA91bGNgTvPF7QExy-2kgfQlC2ghq1MwC4n2mq4EAgwc1NJtXghvhsQN63_xLaUP3SfHiSVyev3VTbyFwJRV9_gVhmjhKoyo-LmfF_Zat7nDKDHTS4SdCm98aEq9tb2WHPLVI8C4cES';
  String toParams = "/topics/" + uidd;

  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);
  final data = {
    "notification": {
      "body": "$amount Wallet Points $s",
      "title": "$amount Wallet Points $s"
    },
    "priority": "high",
    "data": {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "title": "$amount Wallet Points $s",
      "amount": amount,
      "vendorUID": uid,
      "type": "wallet",
    },
    "to": toParams
  };

  final headers = {
    'content-type': 'application/json',
    'Authorization': 'key=' + token
  };

  final response = await http.post(Uri.parse(postUrl),
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
      headers: headers);

  if (response.statusCode == 200) {
// on success do
    // Fluttertoast.showToast(msg: "Notification Sent to tageted city");
  } else {
// on failure do
    Fluttertoast.showToast(msg: "Notification Not Sent");
  }
}
