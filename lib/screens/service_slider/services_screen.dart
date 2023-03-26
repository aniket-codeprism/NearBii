// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:nearbii/Model/services.dart';
import 'package:nearbii/components/search_bar.dart';
import 'package:nearbii/components/service_custom_card.dart';
import 'package:nearbii/screens/bottom_bar/bottomBar/bottomBar.dart';

import 'package:nearbii/screens/service_slider/more_services.dart';

import 'package:nearbii/screens/service_slider/searchvendor.dart';

import '../../constants.dart';
import "package:velocity_x/velocity_x.dart";

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({Key? key}) : super(key: key);

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  var val = "";

  Future<String> getData() {
    return Future.delayed(Duration(seconds: 2), () {
      return "I am data";
      // throw Exception("Custom Error");
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchBar(
                search: (val) async {
                  setState(() {
                    ServicesList.list = [];
                    print(val);
                    if (val.toString().isEmptyOrNull) {
                      print("empty");
                      ServicesList.list = ServicesList.alldata;
                    } else {
                      final List<dynamic> cat = [];
                      ServicesList.list.add(
                          ServicesData(title: "Search Result", category: cat));
                      for (var elemnt in ServicesList.alldata) {
                        for (var catergor in elemnt.category) {
                          if (catergor["title"]
                              .toString()
                              .toLowerCase()
                              .contains(val.toString().toLowerCase())) {
                            ServicesList.list[0].category.add(catergor);
                          }
                        }
                      }
                    }
                  });
                },
                val: "",
              ),
              const SizedBox(
                height: 23,
              ),
              SizedBox(
                height: 15,
                width: double.infinity,
                child: ListView.builder(
                  itemCount: ServicesList.list.isNotEmpty
                      ? ServicesList.list.length
                      : 0,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MoreServices(index: index)));
                            },
                            child: Text(ServicesList.list[index].title)),
                        const SizedBox(
                          width: 16,
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              SizedBox(
                width: double.infinity,
                child: FutureBuilder(
                  future: getData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      // If we got an error
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            '${snapshot.error} occured',
                            style: TextStyle(fontSize: 18),
                          ),
                        );

                        // if we got our data
                      } else if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: ServicesList.list.isNotEmpty
                              ? ServicesList.list.length
                              : 0,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return true
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MoreServices(
                                                          index: index)));
                                        },
                                        child: Text(
                                            ServicesList.list[index].title ==
                                                    "ZZMore"
                                                ? ServicesList.list[index].title
                                                    .substring(2)
                                                : ServicesList
                                                    .list[index].title,
                                            style: TextStyle(
                                              fontSize: 18,
                                            )),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithMaxCrossAxisExtent(
                                                maxCrossAxisExtent: 200,
                                                childAspectRatio: 2.5,
                                                crossAxisSpacing: 20,
                                                mainAxisSpacing: 20),
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: ServicesList.list[index]
                                                    .category.length >=
                                                6
                                            ? 6
                                            : ServicesList
                                                .list[index].category.length,
                                        itemBuilder: (context, indx) {
                                          return indx < 5
                                              ? ServiceCustomCard(
                                                  title: ServicesList
                                                      .list[index]
                                                      .category[indx]['title']
                                                      .toString(),
                                                  image: ServicesList
                                                              .list[index]
                                                              .category[indx]
                                                          ['image'] ??
                                                      '',
                                                ).onInkTap(() {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              SearchVendor(ServicesList
                                                                      .list[index]
                                                                      .category[
                                                                  indx]['title'])));
                                                })
                                              : GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                MoreServices(
                                                                    index:
                                                                        index)));
                                                  },
                                                  child: ServiceCustomCard(
                                                    dot: true,
                                                  ),
                                                );
                                        },
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                    ],
                                  )
                                : SizedBox(height: 0);
                          },
                        );
                      }
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              // Container(
              //   width: double.infinity,
              //   child: FutureBuilder(
              //     future: getData(),
              //     builder: (context, snapshot) {
              //       if (snapshot.connectionState == ConnectionState.done) {
              //         // If we got an error
              //         if (snapshot.hasError) {
              //           return Center(
              //             child: Text(
              //               '${snapshot.error} occured',
              //               style: TextStyle(fontSize: 18),
              //             ),
              //           );

              //           // if we got our data
              //         } else if (snapshot.hasData) {
              //           return ListView.builder(
              //             itemCount: TitleList.data.isNotEmpty ? 1 : 0,
              //             shrinkWrap: true,
              //             physics: NeverScrollableScrollPhysics(),
              //             itemBuilder: (context, index) {
              //               return Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   GestureDetector(
              //                     onTap: () {
              //                       Navigator.push(
              //                           context,
              //                           MaterialPageRoute(
              //                               builder: (context) => MoreScreen(
              //                                   index: TitleList.data
              //                                       .indexOf("More"))));
              //                     },
              //                     child: Text(
              //                         ServicesList
              //                             .list[TitleList.data.indexOf("More")]
              //                             .title,
              //                         style: TextStyle(
              //                           fontSize: 18,
              //                         )),
              //                   ),
              //                   const SizedBox(
              //                     height: 12,
              //                   ),
              //                   GridView.builder(
              //                     gridDelegate:
              //                         SliverGridDelegateWithMaxCrossAxisExtent(
              //                             maxCrossAxisExtent: 200,
              //                             childAspectRatio: 2.5,
              //                             crossAxisSpacing: 20,
              //                             mainAxisSpacing: 20),
              //                     shrinkWrap: true,
              //                     physics: NeverScrollableScrollPhysics(),
              //                     itemCount: ServicesList
              //                                 .list[TitleList.data
              //                                     .indexOf("More")]
              //                                 .category
              //                                 .length >=
              //                             6
              //                         ? 6
              //                         : ServicesList
              //                             .list[index].category.length,
              //                     itemBuilder: (context, indx) {
              //                       return indx < 5
              //                           ? ServiceCustomCard(
              //                               title: ServicesList
              //                                   .list[TitleList.data
              //                                       .indexOf("More")]
              //                                   .category[indx]['title'],
              //                               image: ServicesList
              //                                   .list[TitleList.data
              //                                       .indexOf("More")]
              //                                   .category[indx]['image'],
              //                             )
              //                           : GestureDetector(
              //                               onTap: () {
              //                                 Navigator.push(
              //                                     context,
              //                                     MaterialPageRoute(
              //                                         builder: (context) =>
              //                                             MoreScreen(
              //                                                 index: TitleList
              //                                                     .data
              //                                                     .indexOf(
              //                                                         "More"))));
              //                               },
              //                               child: ServiceCustomCard(
              //                                 dot: true,
              //                               ),
              //                             );
              //                     },
              //                   ),
              //                   const SizedBox(
              //                     height: 12,
              //                   ),
              //                 ],
              //               );
              //             },
              //           );
              //         }
              //       }
              //       return SizedBox();
              //     },
              //   ),
              // ),
              // // GestureDetector(
              //   onTap: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => const TravelScreen()));
              //   },
              //   child: const Text('Travel',
              //       style: TextStyle(
              //         fontSize: 18,
              //       )),
              // ),
              // const SizedBox(
              //   height: 12,
              // ),
              // Row(
              //   children: [
              //     ServiceCustomCard(
              //         title: 'Flight',
              //         image: 'assets/images/travel/flight.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     ServiceCustomCard(
              //         title: 'Resorts',
              //         image: 'assets/images/travel/resort 1.png'),
              //   ],
              // ),
              // const SizedBox(
              //   height: 6,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     ServiceCustomCard(
              //         title: "Train",
              //         image: 'assets/images/travel/train 1.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     ServiceCustomCard(
              //         title: 'Bus',
              //         image: 'assets/images/travel/bus-school 2.png'),
              //   ],
              // ),
              // const SizedBox(
              //   height: 6,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     ServiceCustomCard(
              //         title: "Car Rentals",
              //         image: 'assets/images/travel/car 2.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     GestureDetector(
              //       onTap: () {
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => const TravelScreen()));
              //       },
              //       child: ServiceCustomCard(
              //         dot: true,
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(
              //   height: 28,
              // ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => const DailyNeedsScreen()));
              //   },
              //   child: const Text('Daily Needs',
              //       style: const TextStyle(
              //         fontSize: 18,
              //       )),
              // ),
              // const SizedBox(
              //   height: 12,
              // ),
              // Row(
              //   children: [
              //     ServiceCustomCard(
              //         title: 'Restaurants',
              //         image: 'assets/images/daily_need/restaurant 1.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     ServiceCustomCard(
              //         title: 'Electrician',
              //         image: 'assets/images/travel/resort 1.png'),
              //   ],
              // ),
              // const SizedBox(
              //   height: 6,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     ServiceCustomCard(
              //         title: "AC Service",
              //         image: 'assets/images/daily_need/maintenance 1.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     ServiceCustomCard(
              //         title: 'Grocery',
              //         image: 'assets/images/daily_need/grocery 1.png'),
              //   ],
              // ),
              // const SizedBox(
              //   height: 6,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     ServiceCustomCard(
              //         title: "Plumber",
              //         image: 'assets/images/daily_need/plumbering 1.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     GestureDetector(
              //       onTap: () {
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => const DailyNeedsScreen()));
              //       },
              //       child: ServiceCustomCard(
              //         dot: true,
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(
              //   height: 28,
              // ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => const EducationScreen()));
              //   },
              //   child: const Text('Education',
              //       style: const TextStyle(
              //         fontSize: 18,
              //       )),
              // ),
              // const SizedBox(
              //   height: 12,
              // ),
              // Row(
              //   children: [
              //     ServiceCustomCard(
              //         title: 'Schools',
              //         image: 'assets/images/education/blackboard 2.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     ServiceCustomCard(
              //         title: 'Music Classes',
              //         image:
              //             'assets/images/education/musical-instrument 2.png'),
              //   ],
              // ),
              // const SizedBox(
              //   height: 6,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     ServiceCustomCard(
              //         title: "Colleges",
              //         image: 'assets/images/education/graduate 2.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     ServiceCustomCard(
              //         title: 'Acting Classes',
              //         image: 'assets/images/education/cinema 1.png'),
              //   ],
              // ),
              // const SizedBox(
              //   height: 6,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     ServiceCustomCard(
              //         title: "Universities",
              //         image: 'assets/images/education/university.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     GestureDetector(
              //       onTap: () {
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => const EducationScreen()));
              //       },
              //       child: ServiceCustomCard(
              //         dot: true,
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(
              //   height: 28,
              // ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => const ClothesAndApparel()));
              //   },
              //   child: const Text('Clothes & Apparel',
              //       style: const TextStyle(
              //         fontSize: 18,
              //       )),
              // ),
              // const SizedBox(
              //   height: 12,
              // ),
              // Row(
              //   children: [
              //     ServiceCustomCard(
              //         title: 'Tailor',
              //         image: 'assets/images/clothes_and_apparel/tailor.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     ServiceCustomCard(
              //         title: 'Clothing',
              //         image:
              //             'assets/images/clothes_and_apparel/clothes-rack.png'),
              //   ],
              // ),
              // const SizedBox(
              //   height: 6,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     ServiceCustomCard(
              //         title: "Garments",
              //         image: 'assets/images/clothes_and_apparel/fabric.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     ServiceCustomCard(
              //         title: 'Accessories',
              //         image:
              //             'assets/images/clothes_and_apparel/accessories.png'),
              //   ],
              // ),
              // const SizedBox(
              //   height: 28,
              // ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) =>
              //                 const RepairsAndServicesScreen()));
              //   },
              //   child: const Text('Repairs and Services',
              //       style: const TextStyle(
              //         fontSize: 18,
              //       )),
              // ),
              // const SizedBox(
              //   height: 12,
              // ),
              // Row(
              //   children: [
              //     ServiceCustomCard(
              //         title: 'AC Service',
              //         image:
              //             'assets/images/repairs_and_services/maintenance 1.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     ServiceCustomCard(
              //         title: 'Geyser Repair',
              //         image:
              //             'assets/images/repairs_and_services/water-heater 1.png'),
              //   ],
              // ),
              // const SizedBox(
              //   height: 6,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     ServiceCustomCard(
              //         title: "Computer",
              //         image:
              //             'assets/images/repairs_and_services/online-test 1.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     ServiceCustomCard(
              //         title: 'Motercycle',
              //         image:
              //             'assets/images/repairs_and_services/new bile 3.png'),
              //   ],
              // ),
              // const SizedBox(
              //   height: 6,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     ServiceCustomCard(
              //         title: "Welding",
              //         image: 'assets/images/repairs_and_services/welding.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     GestureDetector(
              //       onTap: () {
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) =>
              //                     const RepairsAndServicesScreen()));
              //       },
              //       child: ServiceCustomCard(
              //         dot: true,
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(
              //   height: 28,
              // ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) =>
              //                 const TrainingInstituteScreen()));
              //   },
              //   child: const Text('Training Institutes',
              //       style: TextStyle(
              //         fontSize: 18,
              //       )),
              // ),
              // const SizedBox(
              //   height: 12,
              // ),
              // Row(
              //   children: [
              //     ServiceCustomCard(
              //         title: 'Administration',
              //         image:
              //             'assets/images/trainingInstitute/hr-manager 2.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     ServiceCustomCard(
              //         title: 'Basic Com..',
              //         image: 'assets/images/trainingInstitute/settings 1.png'),
              //   ],
              // ),
              // const SizedBox(
              //   height: 6,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     ServiceCustomCard(
              //         title: "Web Tech..",
              //         image: 'assets/images/trainingInstitute/technology.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     ServiceCustomCard(
              //         title: 'Programming',
              //         image: 'assets/images/trainingInstitute/code.png'),
              //   ],
              // ),
              // const SizedBox(
              //   height: 6,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     ServiceCustomCard(
              //         title: "Engg. Design",
              //         image: 'assets/images/trainingInstitute/prototype 1.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     GestureDetector(
              //       onTap: () {
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) =>
              //                     const TrainingInstituteScreen()));
              //       },
              //       child: ServiceCustomCard(
              //         dot: true,
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(
              //   height: 28,
              // ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => const StreetFoodScreen()));
              //   },
              //   child: const Text('Street food',
              //       style: TextStyle(
              //         fontSize: 18,
              //       )),
              // ),
              // const SizedBox(
              //   height: 12,
              // ),
              // Row(
              //   children: [
              //     ServiceCustomCard(
              //         title: 'Thela wala',
              //         image: 'assets/images/street-food/tea.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     ServiceCustomCard(
              //         title: 'Chai Tapri',
              //         image: 'assets/images/street-food/tea.png'),
              //   ],
              // ),
              // const SizedBox(
              //   height: 6,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     ServiceCustomCard(
              //         title: "Paan Shops",
              //         image: 'assets/images/street-food/betel-nut.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     ServiceCustomCard(
              //         title: 'Ice-Cream',
              //         image: 'assets/images/street-food/ice-cream.png'),
              //   ],
              // ),
              // const SizedBox(
              //   height: 6,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     ServiceCustomCard(
              //         title: "Fast Food",
              //         image: 'assets/images/street-food/fast-food.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     GestureDetector(
              //       onTap: () {
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => const StreetFoodScreen()));
              //       },
              //       child: ServiceCustomCard(
              //         dot: true,
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(
              //   height: 28,
              // ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(context,
              //         MaterialPageRoute(builder: (context) => MoreScreen()));
              //   },
              //   child: const Text(
              //     'More',
              //     style: TextStyle(
              //       fontSize: 18,
              //     ),
              //   ),
              // ),
              // const SizedBox(
              //   height: 12,
              // ),
              // Row(
              //   children: [
              //     ServiceCustomCard(
              //         title: 'Administration',
              //         image: 'assets/images/more/administration.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     ServiceCustomCard(
              //         title: 'Ayurvedic Dr.',
              //         image: 'assets/images/more/ayurvedic_doctor.png'),
              //   ],
              // ),
              // const SizedBox(
              //   height: 6,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     ServiceCustomCard(
              //         title: "Baby Food",
              //         image: 'assets/images/more/baby_food.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     ServiceCustomCard(
              //         title: 'Baby Sleep',
              //         image: 'assets/images/more/baby_sleep.png'),
              //   ],
              // ),
              // const SizedBox(
              //   height: 6,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     ServiceCustomCard(
              //         title: "Cardiologists",
              //         image: 'assets/images/more/cardiologists.png'),
              //     const SizedBox(
              //       width: 16,
              //     ),
              //     GestureDetector(
              //       onTap: () {
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => MoreScreen()));
              //       },
              //       child: ServiceCustomCard(
              //         dot: true,
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(
              //   height: 28,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
