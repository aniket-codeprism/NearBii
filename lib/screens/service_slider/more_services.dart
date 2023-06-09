// ignore_for_file: unused_local_variable, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:nearbii/Model/services.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/service_slider/searchvendor.dart';
import 'package:velocity_x/velocity_x.dart';
import '../bottom_bar/bottomBar/bottomBar.dart';

class MoreServices extends StatefulWidget {
  final int index;
  const MoreServices({Key? key, required this.index}) : super(key: key);

  @override
  State<MoreServices> createState() => _MoreServicesState();
}

class _MoreServicesState extends State<MoreServices> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      bottomNavigationBar: addBottomBar(context),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Daily Needs label
              Text(
                ServicesList.alldata[widget.index].title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: kLoadingScreenTextColor,
                ),
              ),
              const SizedBox(
                height: 35,
              ),

              Container(
                width: double.infinity,
                height: height * .9,
                child: ListView.builder(
                  itemCount: ServicesList.alldata[widget.index].category.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ListElement(
                      title: ServicesList.alldata[widget.index].category[index]
                          ['title'],
                      imageUrl: ServicesList.alldata[widget.index].category[index]
                          ['image'],
                    ).onInkTap(() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchVendor(ServicesList.alldata[widget.index].category[index]
                          ['title'])));
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListElement extends StatelessWidget {
  const ListElement({
    Key? key,
    required this.imageUrl,
    required this.title,
  }) : super(key: key);

  final String imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              height: 18,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  print(exception);
                  print(stackTrace);

                  return Text('Your error widget...');
                },
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: kLoadingScreenTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 24,
        ),
      ],
    );
  }
}
