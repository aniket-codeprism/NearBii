// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbii/Model/notifStorage.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/services/getOffers/getOffers.dart';
import 'package:nearbii/services/getcity.dart';
import 'package:velocity_x/velocity_x.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  var pos;
  bool isLoading = true;

  var selectedcat = "Category";
  @override
  void initState() {
    // TODO: implement initState
    getCity();
    super.initState();
    load();
  }

  void load() async {
    var poss = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (this.mounted) {
      setState(() {
        pos = poss;
        isLoading = false;
      });
    }
  }

  String city = "";
  getCity() async {
    getCat();
    city = await getcurrentCityFromLocation();
    if (this.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Offers label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Offers",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: kLoadingScreenTextColor,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  height: 20,
                  child: Center(
                    child: DropdownSearch<String>(
                      //mode of dropdown
                      //list of dropdown items
                      // ignore: prefer_const_constructors
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                          textAlignVertical: TextAlignVertical.center,
                          baseStyle: TextStyle(
                              decorationColor: Colors.blue,
                              color: Colors.blue,
                              backgroundColor: Colors.blue,
                              fontSize: 8,
                              overflow: TextOverflow.ellipsis),
                          textAlign: TextAlign.end,
                          dropdownSearchDecoration: InputDecoration.collapsed(
                            hintText: 'City',
                          )),
                      items: CityList.ListCity.map((e) {
                        return e.name;
                      }).toList(),
                      onChanged: ((value) {
                        if (value == null) return;
                        setState(() {
                          city = value;
                        });
                      }),
                      //show selected item\
                      selectedItem: city,
                    ),
                  ),
                ).expand(),
                Container(
                  height: 20,
                  child: Center(
                    child: DropdownSearch<String>(
                        popupProps: PopupProps.menu(
                          constraints: BoxConstraints(maxHeight: 100),
                        ),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration:
                                InputDecoration.collapsed(hintText: 'City')),
                        selectedItem: applied,
                        items: filter.map((e) => e).toList(),
                        onChanged: ((value) {
                          setState(() {
                            if (value == null) return;
                            applied = value.toString();
                          });
                        })),
                  ),
                ).expand(),
                Container(
                  height: 20,
                  child: Center(
                    child: DropdownSearch<String>(
                        popupProps: PopupProps.menu(),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                            textAlignVertical: TextAlignVertical.center,
                            textAlign: TextAlign.end,
                            dropdownSearchDecoration: InputDecoration.collapsed(
                              hintText: 'City',
                            )),
                        selectedItem: selectedcat,
                        items: cat.map((e) => e).toList(),
                        onChanged: ((value) {
                          setState(() {
                            if (value == null) return;
                            selectedcat = value.toString();
                          });
                        })),
                  ),
                ).expand(),
              ],
            ).pOnly(bottom: 10, top: 10, left: 16, right: 0),

            !isLoading
                ? getOffers(context, pos, city, applied, selectedcat)
                : Container(),
          ],
        ).pOnly(top: 20),
      ),
    );
  }

  List<String> filter = ["Discount", "Distance"];
  String applied = "Distance";
  List<String> cat = [];
  Future<void> getCat() async {
    var b = await FirebaseFirestore.instance.collection('Services').get();
    for (var ele in b.docs) {
      cat.add(ele.id);
    }
    if (this.mounted) setState(() {});
  }
}
