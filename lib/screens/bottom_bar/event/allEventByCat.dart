import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/services/getEventByCat/getEventByCat.dart';

class allEventByCat extends StatefulWidget {
  final String cat;
  var pos;
  String city;
  allEventByCat({required this.cat, required this.pos, Key? key, required this.city})
      : super(key: key);

  @override
  State<allEventByCat> createState() => _allEventByCatState();
}

class _allEventByCatState extends State<allEventByCat> {
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
                  "Events in " + widget.cat.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: kLoadingScreenTextColor,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                getEventByCat(context, MediaQuery.of(context).size.height,
                    widget.cat, widget.pos, widget.city),
              ],
            )),
          ),
        ));
  }
}
