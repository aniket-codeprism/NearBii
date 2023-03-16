import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';

class SunburnScreen extends StatefulWidget {
  const SunburnScreen({Key? key}) : super(key: key);

  @override
  State<SunburnScreen> createState() => _SunburnScreenState();
}

class _SunburnScreenState extends State<SunburnScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SUNBURN Concert",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: kLoadingScreenTextColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Container(
                  width: width - 68,
                  height: width - 99,
                  decoration: BoxDecoration(
                    color: kAdvertiseContainerTextColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              Text(
                "Sunburn in Nitte College",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: kLoadingScreenTextColor,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 11),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: kDividerColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 6),
                      child: Text(
                        "Mar 18, 2022",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: kDividerColor,
                        ),
                      ),
                    ),
                    Text(
                      "07:00 PM",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: kSignInContainerColor,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: kDividerColor,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Nitte Colege, Yelahanka, Bangalore",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: kDividerColor,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 25),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 15,
                      color: kDividerColor,
                    ),
                    SizedBox(
                      width: 9.25,
                    ),
                    Text(
                      "7383629373",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: kDividerColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "About",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: kLoadingScreenTextColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: RichText(
                  text: TextSpan(
                    text:
                        'Sunburn Arena makes a massive comeback with one of the world’s best artists ALAN WALKER, performing live for an exclusive India Tour 2022. The hitmaker of Faded, Alone, On My Way and many more award-winning music will be performing live in your city with an ecstatic and scintillating performance!\n\nLimited tickets now LIVE - grab yours now!!\n\nGet ready to Live. Love. Dance. Again!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: kLoadingScreenTextColor,
                    ),
                  ),
                ),
              ),
              Text(
                "Location",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: kLoadingScreenTextColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 101),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: kHintTextColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: Text(
                        '6429, NITTE Meenakshi College Rd, BSF Campus, Yelahanka, Bengaluru, Karnataka 560064',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: kLoadingScreenTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
