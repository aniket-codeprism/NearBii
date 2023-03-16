import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/home/drawer/advertise/event/plans/plans_main_screen.dart';

class AdditionalInformationScreen extends StatefulWidget {
  const AdditionalInformationScreen({Key? key}) : super(key: key);

  @override
  State<AdditionalInformationScreen> createState() =>
      _AdditionalInformationScreenState();
}

class _AdditionalInformationScreenState
    extends State<AdditionalInformationScreen> {
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
              //Advertise Your Business! label
              Text(
                "Additional Information",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: kLoadingScreenTextColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25, bottom: 20),
                child: Column(
                  children: [
                    //Category
                    Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kAdvertiseContainerColor),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(
                                'Category *',
                                style: TextStyle(
                                  color: kAdvertiseContainerTextColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.keyboard_arrow_down_outlined,
                                color: kAdvertiseContainerTextColor,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    //Event Start Date
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kAdvertiseContainerColor),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Text(
                                  'Event Start Date *',
                                  style: TextStyle(
                                    color: kAdvertiseContainerTextColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color: kAdvertiseContainerTextColor,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    //Event End Date
                    Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kAdvertiseContainerColor),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(
                                'Event End Date *',
                                style: TextStyle(
                                  color: kAdvertiseContainerTextColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.calendar_today_outlined,
                                color: kAdvertiseContainerTextColor,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    //Timings
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kAdvertiseContainerColor),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Text(
                                  'Timings *',
                                  style: TextStyle(
                                    color: kAdvertiseContainerTextColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: kAdvertiseContainerTextColor,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    //Notification Date
                    Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kAdvertiseContainerColor),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(
                                'Notification Date *',
                                style: TextStyle(
                                  color: kAdvertiseContainerTextColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Spacer(),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: kAdvertiseContainerTextColor,
                                    size: 18,
                                  ),
                                  SizedBox(
                                    width: 14,
                                  ),
                                  Icon(
                                    Icons.error_outline,
                                    color: kAdvertiseContainerTextColor,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    //Target City
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Target City * ',
                          hintStyle: TextStyle(
                            color: kAdvertiseContainerTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          prefixIconColor: kHintTextColor,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: kAdvertiseContainerColor),
                            gapPadding: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: kAdvertiseContainerColor),
                            gapPadding: 10,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: kAdvertiseContainerColor),
                            gapPadding: 10,
                          ),
                        ),
                      ),
                    ),
                    //Description
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Description *',
                        hintStyle: TextStyle(
                          color: kAdvertiseContainerTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        prefixIconColor: kHintTextColor,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: kAdvertiseContainerColor),
                          gapPadding: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: kAdvertiseContainerColor),
                          gapPadding: 10,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: kAdvertiseContainerColor),
                          gapPadding: 10,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    //add photos
                    GestureDetector(
                      // onTap: () => Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => EventDetailsScreen(),
                      //   ),
                      // ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: kAdvertiseContainerColor),
                          borderRadius: BorderRadius.circular(8.6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: kHomeScreenServicesContainerColor,
                                  borderRadius: BorderRadius.circular(8.69),
                                ),
                                child: Icon(
                                  Icons.add_sharp,
                                  size: 80,
                                  color: kAdvertiseContainerTextColor,
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "Add Photos\n(Optional)",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18,
                                  color: kAdvertiseContainerTextColor,
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
              //make payment button
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PlansMainsScreen(),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: kSignInContainerColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      "Make Payment",
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
