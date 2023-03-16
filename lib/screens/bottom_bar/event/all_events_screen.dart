import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/speech_screen.dart';
import 'package:nearbii/services/getAllEvents/getAllEvents.dart';

class AllEventsScreen extends StatefulWidget {
  const AllEventsScreen({Key? key}) : super(key: key);

  @override
  State<AllEventsScreen> createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends State<AllEventsScreen> {
  final events = ['Concert', 'Art', 'Sports', 'Education', 'Food'];
  final eventIcons = [
    Image.asset(
      'assets/images/events/concert.png',
    ),
    Image.asset('assets/images/events/arts.png'),
    Image.asset('assets/images/events/sports.png'),
    Image.asset('assets/images/events/education.png'),
    Image.asset('assets/images/events/food.png'),
  ];
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Events label
            Text(
              "All Events",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: kLoadingScreenTextColor,
              ),
            ),
            //search box
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: kCircleBorderColor),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Icon(
                          Icons.search_outlined,
                          size: 20,
                          color: kSignInContainerColor,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SpeechScreen(),
                          ),
                        ),
                        child: Icon(
                          Icons.mic_none_outlined,
                          size: 20,
                          color: kSignInContainerColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
