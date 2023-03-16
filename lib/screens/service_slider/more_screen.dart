// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:nearbii/Model/services.dart';
import 'package:nearbii/constants.dart';

class MoreScreen extends StatefulWidget {
  final int index;
  const MoreScreen({Key? key, required this.index}) : super(key: key);

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
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
            //Offers label
            Text(
              "Recent Searches",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: kLoadingScreenTextColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 34),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Image.asset(
                        'assets/icons/handshake.png',
                        height: 40,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "B2b",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: kLoadingScreenTextColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 43,
                  ),
                  Column(
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        child: Image.asset(
                          'assets/images/travel/flight.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "Travel",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: kLoadingScreenTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            //A to Z label
            Text(
              "A to Z",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: kLoadingScreenTextColor,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            SizedBox(
              width: width - 68,
              height: height - 300,
              child: ListView.separated(
                itemCount: ServicesList.alldata[widget.index].category.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 18,
                        width: 18,
                        child: Image.network(
                          ServicesList.alldata[widget.index].category[index]
                              ['image'],
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        ServicesList.alldata[widget.index].category[index]
                            ['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: kLoadingScreenTextColor,
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) => SizedBox(
                  height: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
