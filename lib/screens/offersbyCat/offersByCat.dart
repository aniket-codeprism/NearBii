import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/services/getOffers/getOffers.dart';
import 'package:nearbii/services/getOffersbyFilter/getOffersByFilter.dart';

class OffersByCatScreen extends StatefulWidget {
  final String cat;
  final int off;
  const OffersByCatScreen({Key? key, required this.cat, required this.off})
      : super(key: key);

  @override
  State<OffersByCatScreen> createState() => _OffersByCatScreenState();
}

class _OffersByCatScreenState extends State<OffersByCatScreen> {
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Offers label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Offers",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: kLoadingScreenTextColor,
              ),
            ),
          ),

          getOffersByFilter(context, widget.cat, widget.off),
          // SizedBox(
          //   height: height - 170,
          //   child: Padding(
          //     padding: const EdgeInsets.only(top: 24),
          //     child: ListView.separated(
          //       itemCount: 5,
          //       itemBuilder: (context, index) {
          //         return GestureDetector(
          //           // onTap: () => Navigator.of(context).push(
          //           //   MaterialPageRoute(
          //           //     builder: (context) => categoriesScreenList[index],
          //           //   ),
          //           // ),
          //           child: Padding(
          //             padding: const EdgeInsets.symmetric(horizontal: 29),
          //             child: Stack(
          //               children: [
          //                 Container(
          //                   width: width - 58,
          //                   height: 312,
          //                   decoration: BoxDecoration(
          //                     color: Colors.white,
          //                     borderRadius: BorderRadius.circular(5),
          //                   ),
          //                   child: Image.asset(
          //                     'assets/images/offers/offers_screen_image.png',
          //                     fit: BoxFit.fill,
          //                   ),
          //                 ),
          //                 Positioned(
          //                   top: 15,
          //                   left: 7,
          //                   child: Container(
          //                     width: width - 210,
          //                     decoration: BoxDecoration(
          //                       color: kSignInContainerColor,
          //                       borderRadius: BorderRadius.only(
          //                         topRight: Radius.circular(15),
          //                         bottomRight: Radius.circular(15),
          //                       ),
          //                     ),
          //                     child: Padding(
          //                       padding:
          //                           const EdgeInsets.symmetric(vertical: 10),
          //                       child: Column(
          //                         crossAxisAlignment: CrossAxisAlignment.start,
          //                         children: [
          //                           Text(
          //                             "60% OFF ",
          //                             style: TextStyle(
          //                               fontWeight: FontWeight.w900,
          //                               fontSize: 20,
          //                               color: Colors.white,
          //                             ),
          //                           ),
          //                           Text(
          //                             "on your favourite dishes",
          //                             style: TextStyle(
          //                               fontWeight: FontWeight.w900,
          //                               fontSize: 16,
          //                               color: Colors.white,
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //                 Positioned(
          //                   bottom: 10,
          //                   left: 7,
          //                   child: Container(
          //                     width: width - 72,
          //                     decoration: BoxDecoration(
          //                       color: Colors.white,
          //                       borderRadius: BorderRadius.only(
          //                         bottomLeft: Radius.circular(5),
          //                         bottomRight: Radius.circular(5),
          //                       ),
          //                     ),
          //                     child: Padding(
          //                       padding: const EdgeInsets.symmetric(
          //                           vertical: 12, horizontal: 10),
          //                       child: Row(
          //                         mainAxisAlignment: MainAxisAlignment.start,
          //                         children: [
          //                           Text(
          //                             "VIEW PROFILE",
          //                             style: TextStyle(
          //                               fontWeight: FontWeight.w900,
          //                               fontSize: 18,
          //                               color: kLoadingScreenTextColor,
          //                             ),
          //                           ),
          //                           SizedBox(
          //                             width: 23,
          //                           ),
          //                           Icon(
          //                             Icons.arrow_forward_ios,
          //                             size: 16,
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         );
          //       },
          //       separatorBuilder: (context, index) => SizedBox(
          //         height: 23,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
