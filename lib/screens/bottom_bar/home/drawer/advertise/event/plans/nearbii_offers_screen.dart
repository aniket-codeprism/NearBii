import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';

class NearBiiOffersScreen extends StatefulWidget {
  const NearBiiOffersScreen({Key? key}) : super(key: key);

  @override
  State<NearBiiOffersScreen> createState() => _NearBiiOffersScreenState();
}

class _NearBiiOffersScreenState extends State<NearBiiOffersScreen> {
  @override
  Widget build(BuildContext context) {
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
              //Plans  label
              Text(
                "Plans ",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: kLoadingScreenTextColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 45),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: kPlansDescriptionTextColor,
                        offset: Offset.zero,
                        spreadRadius: 0.1,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 26),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "NearBii Ads",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: kLoadingScreenTextColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5, bottom: 2),
                              child: Text(
                                "Redeem 50 points",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18,
                                  color: kLoadingScreenTextColor,
                                ),
                              ),
                            ),
                            Text(
                              "Get published on our offer page",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 11,
                                color: kPlansDescriptionTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 190,
                        width: double.infinity,
                        color: kHomeScreenServicesContainerColor,
                        child: Image.asset(
                            'assets/images/advertise/plans/nearbii_offers_image.png'),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 37, 20, 64),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: kSignUpContainerColor,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Flexible(
                                  child: Text(
                                    "Publish your poster/post on the offer page. ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: kSignUpContainerColor,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Flexible(
                                    child: Text(
                                      "Notifications to the user within 3kms around you. ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: kSignUpContainerColor,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Flexible(
                                  child: Text(
                                    "Redeem your Nearbii points for publishing offer or buy more via Nearbii wallet. ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: kSignUpContainerColor,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Flexible(
                                  child: Text(
                                    "Valid for 1 day.",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                // onTap: () => Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => eventScreens[trueStateIndex],
                //   ),
                // ),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: kSignInContainerColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      "Post Offer",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 61,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
