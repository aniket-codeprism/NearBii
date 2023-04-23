import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../constants.dart';

class offerBox extends StatefulWidget {
  final data;

  const offerBox({Key? key, required this.data}) : super(key: key);

  @override
  State<offerBox> createState() => _offerBoxState();
}

class _offerBoxState extends State<offerBox> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: const Color.fromARGB(255, 81, 182, 200),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 4,
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 29),
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 58,
                  height: 312,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: widget.data["offerImg"] == ''
                      ? Image.asset(
                          'assets/images/offers/offers_screen_image.png',
                          fit: BoxFit.fill,
                        )
                      : Image.network(
                          widget.data["offerImg"],
                          fit: BoxFit.fill,
                        ),
                ),
                Positioned(
                  top: 15,
                  left: 1,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 210,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(115, 81, 182, 200),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.data["Title"] + " % Off",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.data["subTitle"],
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color.fromARGB(133, 230, 32, 18),
                              ),
                              (widget.data["dis"].toString() + " Km")
                                  .text
                                  .color(
                                      const Color.fromARGB(142, 255, 255, 255))
                                  .make(),
                            ],
                          )
                        ],
                      ).px4(),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "VIEW PROFILE",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: kLoadingScreenTextColor,
                            ),
                          ),
                          const SizedBox(
                            width: 23,
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
