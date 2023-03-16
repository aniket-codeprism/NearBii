import 'package:flutter/material.dart';
import 'package:nearbii/screens/bottom_bar/bottomBar/bottomBar.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/advertise/post_offer_screen.dart';

import '../../constants.dart';
import '../createEvent/addEvent/addEvent.dart';

class SelectAdsScreen extends StatefulWidget {
  const SelectAdsScreen({Key? key}) : super(key: key);

  @override
  State<SelectAdsScreen> createState() => _SelectAdsScreenState();
}

class _SelectAdsScreenState extends State<SelectAdsScreen> {
  Widget myCard(var text) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.80,
      height: 120,
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.all(9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 1,
          color: Color.fromARGB(173, 125, 209, 248),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(241, 246, 247, 1),
              borderRadius: BorderRadius.circular(10),
            ),
            width: 110,
            height: 110,
            child: Icon(Icons.add_outlined,
                size: 60, color: Color.fromRGBO(196, 196, 196, 1)),
          ),
          Container(
              margin: EdgeInsets.only(left: 10),
              child: Text(
                text,
                style: TextStyle(
                    color: Color.fromARGB(255, 203, 207, 207), fontSize: 18),
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        bottomNavigationBar: addBottomBar(context),
        appBar: AppBar(
          leading: Column(
            children: [
              SizedBox(
                width: 45,
                height: 20,
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
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
              child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "Advertise Your Business!",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: kLoadingScreenTextColor,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Image.asset(
                'assets/images/advertise/advertise_main_screen.png',
                width: 300,
                height: 300,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return AddEvent();
                  }));
                },
                child: myCard("Create Event"),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return AddEvent();
                  }));
                },
                child: myCard("Post Ad"),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return PostOfferScreen();
                  }));
                },
                child: myCard("Post Offer"),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
