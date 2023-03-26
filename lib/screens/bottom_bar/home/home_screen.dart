// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:nearbii/components/search_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:developer';
import 'package:animate_icons/animate_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbii/Model/catModel.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/Model/services.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/annual_plan/renew_annual_plan.dart';
import 'package:nearbii/screens/bottom_bar/home/categories/categories_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/about_us_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/advertise/advertise_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/bookmarks_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/privacy_policy_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/settings/settings_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/terms_and_conditions_screen.dart';
import 'package:nearbii/screens/bottom_bar/master_screen.dart';
import 'package:nearbii/screens/notifications_screen.dart';
import 'package:nearbii/screens/service_slider/more_services.dart';
import 'package:nearbii/screens/service_slider/searchvendor.dart';
import 'package:nearbii/screens/service_slider/services_screen.dart';
import 'package:nearbii/services/offerService/getOffers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:velocity_x/velocity_x.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage = 0;
  final controller = PageController();
  String name = '';
  String image = '';
  String number = '';
  String address = '';

  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);

  bool isMember = false;

  var anime = AnimateIconController();

  Future<Position> _determinePosition() async {
    return await Geolocator.getCurrentPosition();
  }

  Future<void> GetAddressFromLatLong() async {
    Position position = await _determinePosition();
    List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude,
        localeIdentifier: "en_US");

    Placemark place = placemarks[0];
    address = '${place.subLocality}, ${place.locality}';

    SharedPreferences session = await SharedPreferences.getInstance();
    var loc = {"lat": position.latitude, "long": position.longitude};
    session.setString("userLocation", place.locality.toString());
    session.setString("pincode", place.postalCode.toString());
    session.setString("LastLocation", jsonEncode(loc));

    if (mounted) {
      setState(() {});
    }
  }

  final geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;

  Future<void> addgeopoints() async {
    Position position = await _determinePosition();
    await Future.delayed(Duration(seconds: 1));
    GeoFirePoint myLocation =
        geo.point(latitude: position.latitude, longitude: position.longitude);
    await _firestore.collection('User').doc(uid).set({
      "position": myLocation.data,
    }, SetOptions(merge: true));
  }

  _fetchUserData() async {
    SharedPreferences session = await SharedPreferences.getInstance();
    if (Notifcheck.userDAta == null) {
      var b =
          await FirebaseFirestore.instance.collection('User').doc(uid).get();
      Notifcheck.userDAta = b.data()!;
      log(b.metadata.isFromCache.toString(), name: "cache");
      log(FirebaseFirestore.instance.settings.persistenceEnabled.toString(),
          name: "cacheEnabled");
      setState(() {
        print('name ${Notifcheck.userDAta!['name']}');
        name = Notifcheck.userDAta!['name'];
        image = Notifcheck.userDAta!['image'];
        number = Notifcheck.userDAta!['phone'];
      });
    } else {
      setState(() {
        print('name ${Notifcheck.userDAta!['name']}');
        name = Notifcheck.userDAta!['name'];
        image = Notifcheck.userDAta!['image'];
        number = Notifcheck.userDAta!['phone'];
      });
      session.setString("type", Notifcheck.userDAta!['type']);

      if (Notifcheck.userDAta!['joinDate'] != null) {
        Map<String, dynamic> memberData = Notifcheck.userDAta!;

        session.setBool("isMember", memberData["isMember"]);

        DateTime memDate =
            DateTime.fromMillisecondsSinceEpoch(memberData["endDate"]);
        // DateTime endDate = memberData["endDate"].toDate();

        session.setString("joinDate", memberData["endDate"].toString());
        var now = DateTime.now();
        end = memDate;
        if (memDate.difference(now).inMilliseconds > 0 &&
            memberData["isMember"]) {
          // Fluttertoast.showToast(msg: "Yes you are member");

          session.setBool("checkIsMember", true);
          setState(() {
            isMember = true;
          });
        } else {
          changeToUser();
          goToUpdateMemberhip();
          session.setBool("checkIsMember", false);
          //Fluttertoast.showToast(msg: "Memberhip Expied");
        }
      } else {}
    }
    if (mounted) {
      setState(() {});
    }
  }

  late DateTime end;

  _gotoService(String data) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MoreServices(index: TitleList.data.indexOf(data))));
  }

  @override
  void initState() {
    addgeopoints();
    super.initState();
    getCategories();
    _fetchUserData();
    GetAddressFromLatLong();
  }

  _sendMail() async {
    // Android and iOS
    const uri = 'mailto:connect@neabii.com?subject=Greetings&body=Hello%20User';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  changeToUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);
    late FirebaseFirestore db;
    db = FirebaseFirestore.instance;

    Map<String, dynamic> userdata = {};

    userdata["type"] = "User";

    Map<String, dynamic> member = {};

    member["isMember"] = false;
    member["joinDate"] = Timestamp.now();

    userdata["member"] = member;

    db
        .collection("User")
        .doc(uid)
        .set(userdata, SetOptions(merge: true))
        .then((value) {
      Fluttertoast.showToast(msg: "Membership Removed");
    });
  }

  goToUpdateMemberhip() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) {
      return RenewAnnualPlanScreen(
        check: false,
        end: end,
      );
    }), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    var offerCard = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x553C828F),
            Color(0x4475A1AA),
            Color(0x11D8D8D8),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 23),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Upto 20% Off",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: kBookmarksAdTextColor,
              ),
            ),
            Text(
              "Home Painting",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: kBookmarksAdTextColor,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: 109,
              height: 32,
              decoration: BoxDecoration(
                color: kSignInContainerColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Book Now",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 15,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
    final offerCards = [
      offerCard,
      offerCard,
      offerCard,
      offerCard,
      offerCard,
      offerCard,
    ];
    bool _allow = true;
    String category = "";
    return Material(
      child: WillPopScope(
        onWillPop: () async {
          return Future.value(_allow);
        },
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              actions: [
                Spacer(),
                SizedBox(
                  width: 65,
                ),
                Center(
                    child: Image.asset(
                  'assets/images/authentication/logo.png',
                  color: Colors.black,
                  height: 80,
                )),
                Spacer(),
                GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NotificationsScreen())),
                    child: ValueListenableBuilder(
                      builder:
                          (BuildContext context, bool value, Widget? child) {
                        return Image.asset(
                          value ? "assets/notif.gif" : "assets/notif.png",
                          height: 25,
                          width: 25,
                        );
                      },
                      valueListenable: Notifcheck.bell,
                    )),
                SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 25,
                ),
              ],
            ),
            drawer: Drawer(
              child: Column(
                children: [
                  Container(
                    color: kSignUpContainerColor,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30.5, bottom: 30),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: ((context) {
                                return MasterPage(
                                  currentIndex: 4,
                                );
                              })), (route) => false);
                            },
                            child: CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                image != ''
                                    ? image
                                    : ' https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=27052833-5800-4721-9429-d21c4a3eac1b',
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: ((context) {
                                    return MasterPage(
                                      currentIndex: 0,
                                    );
                                  })), (route) => false);
                                },
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: kLoadingScreenTextColor,
                                  ),
                                ),
                              ),
                              Text(
                                number.isEmptyOrNull
                                    ? "<Guest>"
                                    : number.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xFF777777),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            width: width - 292,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 20, right: 33),
                      height: double.infinity,
                      width: double.infinity,
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //advertise
                          if (Notifcheck.vendor)
                            Row(
                              children: [
                                SizedBox(
                                  width: 2,
                                ),
                                Icon(
                                  Icons.ads_click,
                                  color: Colors.grey,
                                  size: 20,
                                ).pOnly(right: 10),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AdvertiseScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Advertise",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: kLoadingScreenTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          //Bookmarks
                          Row(
                            children: [
                              SizedBox(
                                width: 2,
                              ),
                              Icon(
                                Icons.bookmark,
                                color: Colors.grey,
                                size: 20,
                              ).pOnly(right: 10),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const BookmarksScreen()),
                                  );
                                },
                                child: Text(
                                  "Bookmarks",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: kLoadingScreenTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          //Settings
                          Row(
                            children: [
                              SizedBox(
                                width: 2,
                              ),
                              Icon(
                                Icons.settings,
                                size: 20,
                                color: Color(0x9932363D),
                              ).pOnly(right: 10),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SettingsScreen()),
                                  );
                                },
                                child: Text(
                                  "Settings",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: kLoadingScreenTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          //Privacy
                          if (false)
                            Row(
                              children: [
                                SizedBox(
                                  width: 2,
                                ),
                                Icon(
                                  Icons.verified_user_outlined,
                                  size: 20,
                                  color: Color(0x9932363D),
                                ).pOnly(right: 10),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const PrivacyPolicyScreen()),
                                    );
                                  },
                                  child: Text(
                                    "Privacy",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: kLoadingScreenTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          //Terms & Conditions
                          if (false)
                            Row(
                              children: [
                                SizedBox(
                                  width: 2,
                                ),
                                Icon(
                                  Icons.padding_rounded,
                                  size: 20,
                                  color: Colors.grey,
                                ).pOnly(right: 10),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const TermsAndConditionsScreen()),
                                    );
                                  },
                                  child: Text(
                                    "Terms & Conditions",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: kLoadingScreenTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          //Rate us
                          Row(
                            children: [
                              SizedBox(
                                width: 2,
                              ),
                              Icon(
                                Icons.star_border,
                                size: 20,
                                color: Colors.grey,
                              ).pOnly(right: 10),
                              TextButton(
                                onPressed: () {
                                  //navigate to playstore
                                  launchUrl(Uri.parse(
                                      "https://play.google.com/store/apps/details?id=com.shellcode.nearbii"));
                                },
                                child: Text(
                                  "Rate us",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: kLoadingScreenTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          //About us
                          Row(
                            children: [
                              SizedBox(
                                width: 2,
                              ),
                              Icon(
                                Icons.error_outline,
                                size: 20,
                                color: Color(0x9932363D),
                              ).pOnly(right: 10),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AboutUsScreen()),
                                  );
                                },
                                child: Text(
                                  "About us",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: kLoadingScreenTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      "Contact Us At".text.make().py2(),
                      "connect@nearbii.com"
                          .text
                          .underline
                          .color(Colors.lightBlue)
                          .make()
                          .onInkTap(() {
                        _sendMail();
                      })
                    ],
                  ).py16()
                ],
              ),
            ),
            body: Container(
              color: Colors.white,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi, $name!",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 20,
                                color: kLoadingScreenTextColor,
                              ),
                            ),
                            Text(
                              address,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Color(0xFF929292),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        SearchVendor(category)));
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Hero(
                                      tag: "searchIcon",
                                      child: Icon(
                                        Icons.search,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ).pOnly(left: 5, right: 5),
                                  TextField(
                                    enabled: false,
                                    decoration: kTextFieldDecoration.copyWith(
                                        contentPadding:
                                            EdgeInsets.only(left: 30),
                                        hintText: 'Get Your Vendors NearBii',
                                        hintStyle:
                                            const TextStyle(fontSize: 14)),
                                    onChanged: (value) {},
                                    onEditingComplete: () {},
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: SizedBox(
                                      height: 30,
                                      width: 50,
                                      child: AvatarGlow(
                                          glowColor: Colors.amber,
                                          duration: const Duration(
                                              milliseconds: 2000),
                                          repeat: true,
                                          repeatPauseDuration:
                                              const Duration(milliseconds: 100),
                                          endRadius: 100,
                                          child: Icon(Icons.mic_off)),
                                    ),
                                  ),
                                ],
                              ),
                            ).pOnly(top: 10),

                            //services
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 25, bottom: 18),
                              child: Row(
                                children: [
                                  Text(
                                    "Services",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      color: kLoadingScreenTextColor,
                                    ),
                                  ),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ServiceScreen())),
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
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 12,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("Services")
                                    .snapshots(),
                                builder: ((BuildContext context,
                                    AsyncSnapshot<
                                            QuerySnapshot<Map<String, dynamic>>>
                                        snapshot) {
                                  if (!snapshot.hasData) {
                                    return CircularProgressIndicator();
                                  }
                                  var data = snapshot.data!.docs;
                                  List<
                                      QueryDocumentSnapshot<
                                          Map<String, dynamic>>> iconVal = [];
                                  for (var ele in data) {
                                    var b = ele;
                                    if (ele.data()["isActive"]) {
                                      iconVal.add(ele);
                                    }
                                  }
                                  int l1 = iconVal.length ~/ 2;
                                  int l2 = iconVal.length - l1;

                                  log(l1.toString() +
                                      " " +
                                      l2.toString() +
                                      " " +
                                      iconVal.length.toString());
                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: width - 40,
                                            height: 80,
                                            child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: l1,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                var iconData = iconVal[index];
                                                var img = (iconData
                                                            .data()
                                                            .containsKey(
                                                                "image") &&
                                                        iconData.data()[
                                                                "image"] !=
                                                            null)
                                                    ? iconData.data()["image"]
                                                    : "https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/services%2FAutomobile%2Fbeauty.png?alt=media&token=a6f98ab2-f2f0-4290-b6c1-78ed43dab859";

                                                return InkWell(
                                                  onTap: () {
                                                    _gotoService(iconData.id);
                                                  },
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundColor:
                                                            kHomeScreenServicesContainerColor,
                                                        radius: width / 13.06,
                                                        child: Image.network(
                                                          img,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 70,
                                                        child: Text(
                                                          iconData.id,
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14,
                                                            color:
                                                                kLoadingScreenTextColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              separatorBuilder:
                                                  (context, index) => SizedBox(
                                                width: 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: width - 40,
                                            height: 80,
                                            child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: l2,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                var iconData =
                                                    iconVal[index + l1];
                                                var img = (iconData
                                                            .data()
                                                            .containsKey(
                                                                "image") &&
                                                        iconData.data()[
                                                                "image"] !=
                                                            null)
                                                    ? iconData.data()["image"]
                                                    : "https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/services%2FAutomobile%2Fbeauty.png?alt=media&token=a6f98ab2-f2f0-4290-b6c1-78ed43dab859";

                                                return InkWell(
                                                  onTap: () {
                                                    {
                                                      _gotoService(iconData.id);
                                                    }
                                                  },
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundColor:
                                                            kHomeScreenServicesContainerColor,
                                                        radius: width / 13.06,
                                                        child: Image.network(
                                                          img,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 70,
                                                        child: Text(
                                                          iconData.id,
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14,
                                                            color:
                                                                kLoadingScreenTextColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              separatorBuilder:
                                                  (context, index) => SizedBox(
                                                width: 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                })),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: getOfferPlates(controller, context),
                      ),
                      Row(
                        children: [
                          Text(
                            "Categories",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: kLoadingScreenTextColor,
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => CategoriesScreen())),
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
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        height: 150,
                        child: Row(
                          children: [
                            ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                var item = categories[index];
                                return Container(
                                  width: 90,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                    image: DecorationImage(
                                        image: NetworkImage(item.image),
                                        fit: BoxFit.fill),
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xffffeb3b),
                                        Color(0xffF57F17),
                                        Color(0xfff9a825),
                                        Color(0xff403A3A),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 14,
                                        width: 90,
                                        color: Colors.white,
                                        child: Center(
                                          child: Text(
                                            item.name,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ).onInkTap(() {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SearchVendor(item.name)),
                                  );
                                }).pOnly(bottom: 2, left: 1);
                              },
                              separatorBuilder: (context, i) {
                                return Padding(
                                  padding: EdgeInsets.only(left: 5, right: 5),
                                );
                              },
                              itemCount: categories.length,
                            ).expand(),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 28,
                      ),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("Services")
                              .snapshots(),
                          builder: ((BuildContext context,
                              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                            var data = snapshot.data!.docs;
                            return ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: ((context, index) {
                                  var res = data[index];
                                  if (res["order"] == -1 ||
                                      res["order"] == null) {
                                    return Container();
                                  }

                                  List sub = [];
                                  for (var ele in res.data()["subcategory"]) {
                                    ele["order"] = ele.containsKey("order")
                                        ? ele["order"]
                                        : -1;
                                    ele["bg"] = ele.containsKey("bg")
                                        ? ele["bg"]
                                        : "https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/services%2FAutomobile%2Fwashing-machine-repair-in-raipur%201.png?alt=media&token=2bbcbc53-bcf0-4fbc-8d4a-dd115a931c61";
                                    if (ele["order"] != -1 &&
                                        ele["order"] != null) {
                                      sub.add(ele);
                                    }
                                  }
                                  if (sub.isEmpty) {
                                    return Container();
                                  }

                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          res.id.text
                                              .fontWeight(FontWeight.w600)
                                              .xl2
                                              .make(),
                                          Spacer(),
                                          "See All".text.bold.make(),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 10,
                                          )
                                        ],
                                      ).onInkTap(() {
                                        _gotoService(res.id);
                                      }),
                                      GridView.builder(
                                          itemCount:
                                              sub.length > 4 ? 4 : sub.length,
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2),
                                          itemBuilder: ((context, index) {
                                            print("carding");
                                            Map subcat = sub[index];
                                            return Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey,
                                                      offset: Offset(
                                                          0.0, 1.0), //(x,y)
                                                      blurRadius: 6.0,
                                                    ),
                                                  ],
                                                  image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: NetworkImage(
                                                          subcat["bg"]))),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    color: Colors.white,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width: 140,
                                                          child: subcat["title"]
                                                              .toString()
                                                              .text
                                                              .ellipsis
                                                              .lg
                                                              .color(
                                                                  Colors.black)
                                                              .bold
                                                              .make()
                                                              .pOnly(
                                                                  bottom: 6,
                                                                  left: 6),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ).onInkTap(() {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SearchVendor(subcat[
                                                              "title"])));
                                            }).p8();
                                          })),
                                      // if (index == 0 && !Notifcheck.vendor)
                                      //   Center(
                                      //     child: Container(
                                      //       height: 90,
                                      //       width: 1000,
                                      //       child: ElevatedButton(
                                      //         child: "Sign Up".text.make(),
                                      //         onPressed: () {},
                                      //       ),
                                      //       decoration: BoxDecoration(
                                      //           image: DecorationImage(
                                      //         image: AssetImage(
                                      //           'assets/Signup.png',
                                      //         ),
                                      //         fit: BoxFit.cover,
                                      //       )),
                                      //     ),
                                      //   ).p8(),
                                    ],
                                  ).centered();
                                }),
                                itemCount: data.length);
                          })).pOnly(bottom: 40),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("generalData")
                              .doc("banners")
                              .collection("advertisement")
                              .snapshots(),
                          builder: ((BuildContext context,
                              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                            var data = snapshot.data!.docs;
                            return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: ((context, index) {
                                  var res = data[index];
                                  return Container(
                                    height: 132,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image:
                                                NetworkImage(res["imageUrl"]),
                                            fit: BoxFit.fill),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        // Row(
                                        //   children: [
                                        //     SizedBox(
                                        //       width: MediaQuery.of(context)
                                        //               .size
                                        //               .width -
                                        //           150,
                                        //       child: res["name"]
                                        //           .toString()
                                        //           .text
                                        //           .make(),
                                        //     )
                                        //   ],
                                        // ),
                                        // Spacer(),
                                        // Row(
                                        //   children: [
                                        //     Container(
                                        //       height: 26,
                                        //       width: 87,
                                        //       decoration: BoxDecoration(
                                        //           color: Color(0xffBE51C8),
                                        //           borderRadius: BorderRadius.all(
                                        //               Radius.circular(7))),
                                        //       child: Center(
                                        //         child: Text(
                                        //           'Know more',
                                        //           style: TextStyle(
                                        //             fontSize: 12,
                                        //             color: Colors.white,
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   ],
                                        // )
                                      ],
                                    ).p16(),
                                  ).centered();
                                }),
                                itemCount: data.length);
                          })),
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: SizedBox(
                          height: 87,
                          width: 1000,
                          child: Image.asset(
                              'assets/images/authentication/logo.png'),
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<CategoriesModel> categories = [];
  getCategories() async {
    var b = await FirebaseFirestore.instance.collection("categories").get();
    int i = 0;
    for (var elemnt in b.docs) {
      if (i > 4) break;
      var cat = CategoriesModel.fromMap(elemnt.data());
      categories.add(cat);
      i++;
    }
    if (mounted) setState(() {});
  }
}
