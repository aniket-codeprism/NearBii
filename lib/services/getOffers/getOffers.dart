import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbii/screens/bottom_bar/profile/vendor_profile_screen.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../constants.dart';

Widget getOffers(BuildContext context, var pos, String city, String applied,
    String selectedcat) {
  var height = MediaQuery.of(context).size.height;
  FirebaseFirestore.instance
      .collection("User")
      .doc(FirebaseAuth.instance.currentUser!.uid.substring(0, 20))
      .set({"offerNotif": false}, SetOptions(merge: true));

  try {
    final _firestore = selectedcat == "Category"
        ? city != 'All India'
            ? FirebaseFirestore.instance
                .collection('Offers')
                .where("city", isEqualTo: city)
            : FirebaseFirestore.instance.collection('Offers')
        : FirebaseFirestore.instance
            .collection('Offers')
            .where("city", isEqualTo: city)
            .where("category", isEqualTo: selectedcat);

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.snapshots().handleError((error) {
        return Container(
          child: const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(),
          ),
        );
      }),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        List dmta = snapshot.data!.docs;
        List ndmta = [];

        if (dmta.isEmpty) {
          return Center(
            child: "Nothing to Show".text.make().py12(),
          );
        }
        for (var ele in dmta) {
          Map deta = ele.data();
          var dis = Geolocator.distanceBetween(
                pos.latitude,
                pos.longitude,
                ele.data()["location"]["lat"],
                ele.data()["location"]["long"],
              ) /
              1000;
          deta.addEntries({"dis": dis.toDoubleStringAsFixed(digit: 3)}.entries);

          deta.addEntries({"ref": ele.reference}.entries);
          log(ele.reference.toString());
          ndmta.add(deta);
          log(deta.toString());
        }
        if (applied == "Distance") {
          ndmta.sort(
            (a, b) {
              return a["dis"].compareTo(b["dis"]);
            },
          );
        } else {
          ndmta.sort(
            (a, b) {
              return b["Title"].compareTo(a["Title"]);
            },
          );
        }
        log(ndmta.first["dis"].toString());

        List<Widget> messageWidgets = ndmta.map<Widget>((m) {
          final data = m as dynamic;
          var dis = 5;

          {
            print(data['date']);
            Timestamp ts = data['date'];
            DateTime dt =
                DateTime.fromMillisecondsSinceEpoch(ts.millisecondsSinceEpoch);
            final difference = DateTime.now().difference(dt).inSeconds;
            double limit = 86400;
            print(difference);
            if (difference <= limit) {
              return InkWell(
                  onTap: () async {
                    Future.delayed(const Duration(milliseconds: 5));
                    await Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return VendorProfileScreen(
                        id: data["uid"],
                        isVisiter: true,
                      );
                    }));
                  },
                  child: offerBox(
                    data: data,
                  ));
            } else {
              m["ref"].delete();
            }
          }

          return Container();
        }).toList();

        return Container(
          padding: const EdgeInsets.only(top: 10),
          child: SizedBox(
            height: height - MediaQuery.of(context).size.height / 3.8,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListView.separated(
                scrollDirection: Axis.vertical,
                itemCount: messageWidgets.length,
                itemBuilder: (context, index) {
                  return messageWidgets[index];
                },
                separatorBuilder: (context, index) => const SizedBox(
                  width: 15,
                ),
              ),
            ),
          ),
        );
      },
    );
  } catch (Ex) {
    print("0x1Error To Get User");
    return const SizedBox(
      width: 30,
      height: 30,
      child: CircularProgressIndicator(),
    );
  }
}

class offerBox extends StatefulWidget {
  final data;

  const offerBox({Key? key, required this.data}) : super(key: key);

  @override
  State<offerBox> createState() => _offerBoxState();
}

class _offerBoxState extends State<offerBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        elevation: 4,
        child: Container(
            padding: const EdgeInsets.only(top: 25),
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
                                    .color(const Color.fromARGB(142, 255, 255, 255))
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
      ),
    );
  }
}
