import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/services/getEventByCat/getEventByCat.dart';
import 'package:nearbii/services/getEventByDate/getEventByDate.dart';
import 'package:nearbii/services/getcity.dart';

class allEventByDate extends StatefulWidget {
  final DateTime date;
  allEventByDate({required this.date, Key? key}) : super(key: key);

  @override
  State<allEventByDate> createState() => _allEventByDateState();
}

class _allEventByDateState extends State<allEventByDate> {
  String userLocation = "";

  @override
  void initState() {
    // TODO: implement initState
    getCity();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
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
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
                child: Column(
              children: [
                Text(
                  "Events in " +
                      DateFormat('yyyy-MM-dd').format(widget.date).toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: kLoadingScreenTextColor,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                getEventByDate(context, widget.date.millisecondsSinceEpoch,
                    MediaQuery.of(context).size.height, pos, userLocation),
              ],
            )),
          ),
        ));
  }

  var pos;
  Future<void> getCity() async {
    userLocation = await getcurrentCityFromLocation();
    pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (this.mounted) setState(() {});
  }
}
