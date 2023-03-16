import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/main.dart';
import 'package:nearbii/screens/authentication/AuthenticationForm.dart';
import 'package:nearbii/screens/bottom_bar/master_screen.dart';
import 'package:nearbii/screens/bottom_bar/permissiondenied_screen.dart';
import 'package:nearbii/services/setUserMode.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTP extends StatefulWidget {
  final String phone;
  final String name;
  final String password;
  const OTP({required this.phone, this.name = 'Guest', this.password = 'fd'});

  @override
  _OTPState createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  final FocusNode _pinPutFocusNode = FocusNode();
  final TextEditingController _pinPutController = TextEditingController();
  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
    ),
    decoration: BoxDecoration(
      border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
      borderRadius: BorderRadius.circular(20),
    ),
  );
  var pinPutDecoration;
  String? token;
  _fetchToken() async {
    token = await FirebaseMessaging.instance.getToken();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
        return PermissionDenied();
      })));
      await Geolocator.openLocationSettings();
      // return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
        return PermissionDenied();
      })));
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: ((context) {
      return MasterPage(
        currentIndex: 0,
      );
    })), (route) => false);
  }

  late String _verificationCode;
  String smsCode = "123456";
  _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${widget.phone}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              smsCode = credential.smsCode!;

              Map<String, dynamic> employeeDetails = {
                "phone": "+91${widget.phone}",
                "token": token,
                "name": widget.name,
                "password": widget.password,
                "type": "User",
                "offerNotif": false,
                "eventNotif": false,
                "newNotif": false,
                "userId": value.user!.uid.substring(0, 20),
                "wallet": 0,
                "image":
                    "https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=27052833-5800-4721-9429-d21c4a3eac1b",
              };
              FirebaseFirestore.instance
                  .collection("User")
                  .doc(value.user!.uid.substring(0, 20))
                  .get()
                  .then((values) async {
                var data = values.data();
                print(data);
                if (data == null) {
                  FirebaseFirestore.instance
                      .collection("User")
                      .doc(value.user!.uid.substring(0, 20))
                      .set(employeeDetails);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Done')));
                  value.user!.updateDisplayName(widget.name);
                  data = employeeDetails;
                }

                if (data != null) {
                  data["type"] == "User" ? setUserMode() : setVendorMode();
                  _determinePosition();
                } else {
                  setUserMode();
                  _determinePosition();
                }
              });
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
          print(e.message);
        },
        codeSent: (String verficationID, int? resendToken) {
          setState(() {
            _verificationCode = verficationID;
          });
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          _verificationCode = verificationID;
        },
        timeout: const Duration(seconds: 120));
  }

  bool isLoading = false;

  _showNotification(String name) {
    flutterLocalNotificationsPlugin.show(
      0,
      "Welcome To Nearbii",
      "Thank you $name, for choosing NEARBII ❤",
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          color: Colors.blue,
          playSound: true,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
    );
  }

  @override
  void initState() {
    pinPutDecoration ==
        defaultPinTheme.copyDecorationWith(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(
            color: kSignInContainerColor,
          ),
        );
    super.initState();
    _fetchToken();
    _verifyPhone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            size: 15,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Verify phone',
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 19,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Text(
                  'Code is sent to ${widget.phone}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0),
                child: Pinput(
                  length: 6,
                  autofocus: true,

                  focusNode: _pinPutFocusNode,
                  controller: _pinPutController,
                  submittedPinTheme: pinPutDecoration,
                  focusedPinTheme: pinPutDecoration,
                  followingPinTheme: pinPutDecoration,
                  pinAnimationType: PinAnimationType.fade,
                  // onSubmit: (String val){
                  //   print(val);
                  // },
                ),
              ),
              const SizedBox(
                height: 62,
              ),
              InkWell(
                onTap: () {
                  _verifyPhone();
                },
                child: RichText(
                  text: TextSpan(
                      text: 'Didn\'t receive an OTP?  ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: const Color(0xFF676767),
                      ),
                      children: [
                        TextSpan(
                          text: 'Resend OTP',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: kSignInContainerColor,
                          ),
                        ),
                      ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 72),
                child: GestureDetector(
                  onTap: () async {
                    try {
                      smsCode = _pinPutController.text;
                      print("object $smsCode");
                      SharedPreferences sp =
                          await SharedPreferences.getInstance();
                      await FirebaseAuth.instance
                          .signInWithCredential(PhoneAuthProvider.credential(
                              verificationId: _verificationCode,
                              smsCode: smsCode))
                          .then((value) async {
                        if (value.user != null) {
                          Map<String, dynamic> employeeDetails = {
                            "phone": "+91${widget.phone}",
                            "token": token,
                            "name": widget.name,
                            "password": widget.password,
                            "type": "User",
                            "userId": value.user!.uid.substring(0, 20),
                            "wallet": 0,
                            "image":
                                "https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=27052833-5800-4721-9429-d21c4a3eac1b",
                          };
                          FirebaseFirestore.instance
                              .collection("User")
                              .where("phone", isEqualTo: "+91${widget.phone}")
                              .get()
                              .then((values) {
                            if (values.docs.isEmpty) {
                              FirebaseFirestore.instance
                                  .collection("User")
                                  .doc(value.user!.uid.substring(0, 20))
                                  .set(employeeDetails)
                                  .then((value) {
                                setState(() {
                                  isLoading = false;
                                });

                                sp.setBool("user", true);
                                sp.setString("type", "User");
                                _showNotification(widget.name);
                                _determinePosition();
                              });
                            } else {
                              _determinePosition();
                            }
                          });
                        }
                      });
                    } catch (e) {
                      print(e);
                      FocusScope.of(context).unfocus();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('invalid OTP')));
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kSignInContainerColor,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 16),
                      child: Text(
                        'Verify',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
