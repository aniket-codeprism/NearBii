import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';

class ServiceSlider extends StatefulWidget {
  const ServiceSlider({Key? key}) : super(key: key);

  @override
  State<ServiceSlider> createState() => _ServiceSliderState();
}

class _ServiceSliderState extends State<ServiceSlider> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Food",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: kLoadingScreenTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
