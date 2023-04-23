// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/bottom_bar/bottomBar/bottomBar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

class ViewEvent extends StatefulWidget {
  final data;
  double dis;
  ViewEvent({required this.data, Key? key, required this.dis})
      : super(key: key);

  @override
  State<ViewEvent> createState() => _ViewEventState();
}

class _ViewEventState extends State<ViewEvent> {
  List imageList = [];
  @override
  void initState() {
    // TODO: implement initState
    imageList = widget.data()["eventImage"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: addBottomBar(context),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  "Event Info",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: kLoadingScreenTextColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
                child: widget.data()["eventImage"] != ""
                    ? VxSwiper(
                        height: 300,
                        scrollDirection: Axis.horizontal,
                        enableInfiniteScroll: false,
                        autoPlay: false,
                        enlargeCenterPage: true,
                        reverse: false,
                        isFastScrollingEnabled: false,
                        onPageChanged: (value) {
                          print(value);
                        },
                        autoPlayCurve: Curves.elasticOut,
                        items: imageList.map((e) {
                          return InteractiveViewer(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: ClipRect(
                                  child: Image.network(
                                e,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                              )),
                            ),
                          ).onTap(() {
                            showGeneralDialog(
                                barrierColor:
                                    const Color.fromARGB(103, 26, 26, 26),
                                context: context,
                                pageBuilder: (BuildContext context,
                                    Animation<double> animation,
                                    Animation<double> secondaryAnimation) {
                                  return Center(
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: VxSwiper(
                                          viewportFraction: 1.0,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          scrollDirection: Axis.horizontal,
                                          scrollPhysics:
                                              const BouncingScrollPhysics(),
                                          enableInfiniteScroll: false,
                                          autoPlay: false,
                                          reverse: false,
                                          pauseAutoPlayOnTouch:
                                              const Duration(seconds: 3),
                                          isFastScrollingEnabled: false,
                                          onPageChanged: (value) {
                                            print(value);
                                          },
                                          autoPlayCurve: Curves.elasticOut,
                                          items: imageList.map((e) {
                                            return InteractiveViewer(
                                                child: Image.network(e));
                                          }).toList()),
                                    ),
                                  );
                                });
                          });
                        }).toList())
                    : Image.network(
                        "https://thumbs.dreamstime.com/b/event-planning-working-desk-notebook-events-word-computer-pencil-notepad-clock-concept-98612010.jpg"),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.data()["name"].toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: kLoadingScreenTextColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  const Icon(
                    Icons.calendar_month,
                    color: Color.fromARGB(255, 211, 211, 211),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    DateFormat("dd-MM-yyyy").format(
                        DateTime.fromMillisecondsSinceEpoch(
                            widget.data()["eventStartDate"])),
                    style: const TextStyle(
                        color: Color.fromARGB(255, 211, 211, 211)),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget.data()["eventTime"],
                    style: const TextStyle(
                        color: Color.fromARGB(255, 29, 202, 224)),
                  )
                ]),
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width * .6,
                  child: const Text('to',
                      style: TextStyle(
                          color: Color.fromARGB(255, 211, 211, 211)))),
              //end date
              Container(
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  const Icon(
                    Icons.calendar_month,
                    color: Color.fromARGB(255, 211, 211, 211),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    DateFormat("dd-MM-yyyy").format(
                        DateTime.fromMillisecondsSinceEpoch(
                            widget.data()["eventEndData"])),
                    style: const TextStyle(
                        color: Color.fromARGB(255, 211, 211, 211)),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ]),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Color.fromARGB(255, 211, 211, 211),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget.data()["addr"],
                    style: const TextStyle(
                        color: Color.fromARGB(255, 211, 211, 211)),
                  ),
                  (widget.dis.toDoubleStringAsFixed(digit: 2) + " Km")
                      .text
                      .color(Colors.grey)
                      .make()
                      .px4()
                      .px(6),
                ]),
              ).onInkTap(() {
                print(widget.data()["eventLocation"]["long"]);
                MapsLauncher.launchCoordinates(
                    widget.data()["eventLocation"]["lat"],
                    widget.data()["eventLocation"]["long"]);

                // Navigator.of(context)
                //     .push(MaterialPageRoute(builder: (context) {
                //   return GoogleMapScreen(
                //     long:
                //         widget.data()["eventLocation"]["long"],
                //     lat:
                //         widget.data()["eventLocation"]["lat"],
                //     show: false,
                //   );
                // }));
              }),
              InkWell(
                onTap: () async {
                  var mobbbb = widget.data()["mobo"].toString();
                  var url = "tel:$mobbbb";
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Row(children: [
                    const Icon(
                      Icons.call_outlined,
                      color: Color.fromARGB(255, 211, 211, 211),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () async {
                        var mobbbb = widget.data()["mobo"].toString();
                        var url = "tel:$mobbbb";
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Text(
                        widget.data()["mobo"],
                        style: const TextStyle(
                            color: Color.fromARGB(255, 211, 211, 211)),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "About",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: kLoadingScreenTextColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.data()["eventDesc"],
                  style: TextStyle(
                    fontSize: 15,
                    color: kLoadingScreenTextColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Location",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: kLoadingScreenTextColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                child: Row(children: [
                  SizedBox(
                    width: 120,
                    child: InkWell(
                      onTap: () {},
                      child: Image.network(
                          "https://images.unsplash.com/photo-1586449480584-34302e933441?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8Z2VybWFueSUyMG1hcHxlbnwwfHwwfHw%3D&w=1000&q=80"),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.data()["city"],
                      style: TextStyle(
                        fontSize: 15,
                        color: kLoadingScreenTextColor,
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(
                height: 30,
              ),
            ]).px12().py16(),
          ),
        ));
  }
}
