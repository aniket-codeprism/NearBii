import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/advertise/event/plans/nearbii_ads_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/advertise/event/plans/nearbii_events_screen.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/advertise/event/plans/nearbii_offers_screen.dart';

class PlansMainsScreen extends StatefulWidget {
  const PlansMainsScreen({Key? key}) : super(key: key);

  @override
  State<PlansMainsScreen> createState() => _PlansMainsScreenState();
}

class _PlansMainsScreenState extends State<PlansMainsScreen> {
  List<bool> checkBoxState = <bool>[];
  late int trueStateIndex = 6;

  final plansImages = [
    Image.asset('assets/images/advertise/plans/nearbii_events_image.png'),
    Image.asset('assets/images/advertise/plans/nearbii_ads_image.png'),
    Image.asset('assets/images/advertise/plans/nearbii_offers_image.png'),
  ];
  final plans = ['NearBii Events', 'NearBii Ads', 'NearBii Offers'];
  final plansDescription = [
    'Appear on the top  of our list in our category ',
    'Make yourself visible to every user in the target city',
    'Get published on our offer page'
  ];
  final eventScreens = [
    const NearBiiEventsScreen(),
    const NearBiiAdsScreen(),
    const NearBiiOffersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            const SizedBox(
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
              Center(
                child: Image.asset(
                    'assets/images/advertise/plans/plans_main_screen_image.png'),
              ),
              SizedBox(
                height: 470,
                child: ListView.separated(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    checkBoxState.add(false);

                    return Container(
                      width: width - 68,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: kHomeScreenServicesContainerColor,
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 112,
                                  width: 112,
                                  color: Colors.white,
                                  child: plansImages[index],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plans[index].toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 19,
                                          color: kLoadingScreenTextColor,
                                        ),
                                      ),
                                      RichText(
                                        softWrap: true,
                                        text: TextSpan(
                                          text: plansDescription[index],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 11,
                                            color: kPlansDescriptionTextColor,
                                          ),
                                        ),
                                      ),
                                      index != 0
                                          ? Text(
                                              "Valid for 1 day",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 11,
                                                color: kLoadingScreenTextColor,
                                              ),
                                            )
                                          : const SizedBox(),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      index != 0
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Redeem 50 points",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 11,
                                                    color:
                                                        kLoadingScreenTextColor,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 4,
                                                ),
                                                Image.asset(
                                                  'assets/icons/plans/sparkles 1.png',
                                                ),
                                              ],
                                            )
                                          : RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                text: '₹',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 11,
                                                  color:
                                                      kLoadingScreenTextColor,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: '999',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 17,
                                                      color:
                                                          kLoadingScreenTextColor,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: '/event',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 11,
                                                      color:
                                                          kLoadingScreenTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                unselectedWidgetColor: kSignInContainerColor,
                              ),
                              child: Checkbox(
                                checkColor: Colors.white,
                                activeColor: kSignInContainerColor,
                                value: checkBoxState[index],
                                onChanged: (value) {
                                  setState(
                                    () {
                                      checkBoxState[index] =
                                          checkBoxState[index] == false
                                              ? true
                                              : false;
                                      if (trueStateIndex > -1 &&
                                          trueStateIndex < 3) {
                                        checkBoxState[trueStateIndex] = false;
                                      }
                                      trueStateIndex = index;
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 20.18,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (trueStateIndex > -1 && trueStateIndex < 3) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => eventScreens[trueStateIndex],
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: kSignInContainerColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      "Select & Next",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 61,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
