import 'dart:convert';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:nearbii/Model/catModel.dart';
import 'package:nearbii/Model/cityModel.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/components/search_bar.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/event/all_nearby_events/sunburn_concert.dart';
import 'package:nearbii/screens/speech_screen.dart';
import 'package:nearbii/services/getAllEvents/getAllEvents.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearbii/services/getcity.dart';
import 'package:velocity_x/velocity_x.dart';

class AllNearbyEventsScreen extends StatefulWidget {
  AllNearbyEventsScreen({Key? key}) : super(key: key);

  @override
  State<AllNearbyEventsScreen> createState() => _AllNearbyEventsScreenState();
}

class _AllNearbyEventsScreenState extends State<AllNearbyEventsScreen> {
  String query = '';
  var pos = null;
  List<Cities> citites = [];
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
    if (this.mounted) setState(() {});
  }

  var catList = [];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            SizedBox(
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20),
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
              child: Container(
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
                        setState(() {
                          query = quer.toString().toLowerCase();
                        });
                      },
                      val: '',
                    )),
              ),
            ),

            DropdownSearch<String>(
              //mode of dropdown
              //list of dropdown items
              popupProps: PopupProps.menu(
                showSearchBox: true,
              ),
              dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                labelText: "City",
              )),
              items: citites.map((e) {
                return e.name;
              }).toList(),
              onChanged: ((value) {
                setState(() {
                  if (value == null) return;
                  city = value;
                });
              }),
              //show selected item
              selectedItem: city,
            ).px16(),

            Expanded(child: getAllEvents(height, query, city, pos)),
          ],
        ),
      ),
    );
  }
}
