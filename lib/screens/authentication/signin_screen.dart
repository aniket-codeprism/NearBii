// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/authentication/AuthenticationForm.dart';
import 'package:nearbii/screens/authentication/otp_screen.dart';
import 'package:nearbii/screens/bottom_bar/master_screen.dart';
import 'package:nearbii/screens/bottom_bar/permissiondenied_screen.dart';

import '../../Model/notifStorage.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
String? token;

_fetchToken() async {
  token = await FirebaseMessaging.instance.getToken();
}

Future<void> signup(BuildContext context) async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      await googleSignIn.disconnect();
    } on Exception {
      // TODO
    }
    _fetchToken();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount == null) return;
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    // Getting users credential
    UserCredential result = await auth.signInWithCredential(authCredential);
    User? user = result.user;

    Map<String, dynamic> employeeDetails = {
      "phone": auth.currentUser!.phoneNumber,
      "token": token,
      "name": user!.displayName,
      "password": user.email,
      "type": "User",
      "userId": auth.currentUser!.uid.substring(0, 20),
      "wallet": 0,
      "image":
          "https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=27052833-5800-4721-9429-d21c4a3eac1b",
    };
    String randomUUDI = user.uid.substring(0, 20);
    FirebaseFirestore.instance
        .collection("User")
        .where("userId", isEqualTo: randomUUDI)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        _determinePosition(context);
      } else {
        FirebaseFirestore.instance
            .collection("User")
            .doc(randomUUDI)
            .set(employeeDetails)
            .then((value) {
          // Write UserID Store in Secure Data Store

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AuthenticationForm(""),
            ),
          );
        });
      }
    });
  } on Exception {
    // TODO
  }
}

Future<void> _determinePosition(context) async {
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

class Resource {
  final Status status;
  Resource({required this.status});
}

enum Status { Success, Error, Cancelled }

Future<Resource?> signInWithFacebook(BuildContext context) async {
  _fetchToken();
  try {
    final LoginResult result = await FacebookAuth.instance
        .login(permissions: ["public_profile", "email"]);
    switch (result.status) {
      case LoginStatus.success:
        final AuthCredential facebookCredential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        final userCredential =
            await auth.signInWithCredential(facebookCredential);
        Map<String, dynamic> employeeDetails = {
          "phone": auth.currentUser!.phoneNumber,
          "token": token,
          "name": auth.currentUser!.displayName,
          "password": "",
          "userId": auth.currentUser!.uid.substring(0, 20),
          "type": "User",
          "wallet": 0,
          "image":
              "https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=27052833-5800-4721-9429-d21c4a3eac1b",
        };

        FirebaseFirestore.instance
            .collection("User")
            .where("userId", isEqualTo: auth.currentUser!.uid.substring(0, 20))
            .get()
            .then((value) {
          if (value.docs.isEmpty) {
            FirebaseFirestore.instance
                .collection("User")
                .doc(auth.currentUser!.uid.substring(0, 20))
                .set(employeeDetails)
                .then((value) {
              // Navigator.of(context).pushReplacement(
              //   MaterialPageRoute(
              //     builder: (context) => const MasterPage(),
              //   ),
              // );
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => AuthenticationForm("")),
                  (route) => true);
            });
          } else {
            Map<String, dynamic> employeeDetail = {
              "phone": auth.currentUser!.phoneNumber,
              "token": token,
              "name": auth.currentUser!.displayName,
              "password": "",
              "userId": auth.currentUser!.uid.substring(0, 20),
              "wallet": 0,
              "image":
                  "https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=27052833-5800-4721-9429-d21c4a3eac1b",
            };
            FirebaseFirestore.instance
                .collection("User")
                .doc(auth.currentUser!.uid.substring(0, 20))
                .set(employeeDetail, SetOptions(merge: true));
            _determinePosition(context);
          }
        });

        return Resource(status: Status.Success);
      case LoginStatus.cancelled:
        return Resource(status: Status.Cancelled);
      case LoginStatus.failed:
        return Resource(status: Status.Error);
      default:
        return null;
    }
  } on FirebaseAuthException {
    rethrow;
  }
}

class LoginSignUpScreen extends StatefulWidget {
  final bool loginState;

  const LoginSignUpScreen({
    Key? key,
    required this.loginState,
  }) : super(key: key);

  @override
  State<LoginSignUpScreen> createState() => _LoginSignUpScreenState();
}

class _LoginSignUpScreenState extends State<LoginSignUpScreen> {
  bool loginState = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loginState = widget.loginState;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, //new line
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 30, 8, 0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: loginState
                            ? kSignInContainerColor
                            : Colors.transparent,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "Sign in",
                      ),
                    ),
                    onTap: () => setState(() {
                      loginState = true;
                    }),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      loginState = false;
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: !loginState
                              ? kSignInContainerColor
                              : Colors.transparent),
                      padding: const EdgeInsets.all(8),
                      child: Text("Sign up"),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 122,
              child: loginState ? SignInScreen() : SignUpScreen(),
            )
          ],
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final mobileController = TextEditingController();
  // final passwordController = TextEditingController();
  // final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final formGlobalKey = GlobalKey<FormState>();

  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;

  @override
  void dispose() {
    mobileController.dispose();
    // passwordController.dispose();
    // confirmPasswordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: formGlobalKey,
          child: Padding(
            padding: const EdgeInsets.only(top: 55, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //let's go label
                Text(
                  'Lets Go!',
                  style: TextStyle(
                    color: kLoadingScreenTextColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 10),
                  child: Column(
                    children: [
                      //name field
                      SizedBox(
                        height: 50,
                        child: TextFormField(
                          //controller: mobileController,
                          keyboardType: TextInputType.text,
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: 'Full Name',
                            hintStyle: TextStyle(
                                color: kHintTextColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixIcon: Icon(
                              Icons.person_outline,
                              size: 20,
                            ),
                            prefixIconColor: kHintTextColor,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 13,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2),
                              borderSide:
                                  BorderSide(color: kSignInContainerColor),
                              gapPadding: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2),
                              borderSide:
                                  BorderSide(color: kSignInContainerColor),
                              gapPadding: 10,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2),
                              borderSide:
                                  BorderSide(color: kSignInContainerColor),
                              gapPadding: 10,
                            ),
                          ),
                        ),
                      ),
                      //number field
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 25),
                        child: SizedBox(
                          height: 50,
                          child: TextFormField(
                            controller: mobileController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Number',
                              hintStyle: TextStyle(
                                  color: kHintTextColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                size: 20,
                              ),
                              prefixIconColor: kHintTextColor,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2),
                                borderSide:
                                    BorderSide(color: kSignInContainerColor),
                                gapPadding: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2),
                                borderSide:
                                    BorderSide(color: kSignInContainerColor),
                                gapPadding: 10,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2),
                                borderSide:
                                    BorderSide(color: kSignInContainerColor),
                                gapPadding: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //sign in button
                GestureDetector(
                  onTap: () {
                    if (formGlobalKey.currentState!.validate()) {
                      formGlobalKey.currentState!.save();
                      Notifcheck.currentVendor = null;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => OTP(
                                  phone: mobileController.text,
                                  name: nameController.text,
                                  password: 'test1234',
                                )),
                      );
                    }
                  },
                  child: Container(
                    width: width - 68,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: kSignInContainerColor,
                    ),
                    child: Center(
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                //divider
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Divider(
                          color: kHintTextColor,
                        ),
                      ),
                      Text(
                        'Or ',
                        style: TextStyle(
                          color: kDividerColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Expanded(
                        child: Divider(
                          color: kHintTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                //google container
                GestureDetector(
                  onTap: () {
                    signup(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: kSignInContainerColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 3,
                          ),
                          Image.asset(
                            'assets/icons/google.png',
                            height: 25,
                            width: 25,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Text(
                            'Continue with google',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                //facebook
                GestureDetector(
                  onTap: () {
                    signInWithFacebook(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: kSignInContainerColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.facebook,
                            size: 25,
                            color: Colors.blue.shade900,
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Text(
                            'Continue with facebook',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //bottom label
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 67),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account?',
                      style: TextStyle(
                        color: kLoadingScreenTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(
                          text: '  Sign In',
                          style: TextStyle(
                            color: kSignInBottomLabelColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginSignUpScreen(
                                            loginState: true)),
                                  ),
                                },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final mobileController = TextEditingController();

  _checkUser() async {
    await FirebaseFirestore.instance
        .collection('User')
        .where('phone', isEqualTo: '+91${mobileController.text}')
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OTP(
              phone: mobileController.text,
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: 'Account does not exist! Create Account');
      }
    });
  }

  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 55, left: 34, right: 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //let's go label
              Text(
                'Lets Go!',
                style: TextStyle(
                  color: kLoadingScreenTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              //textfield
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: SizedBox(
                  height: 50,
                  child: TextFormField(
                    controller: mobileController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
                      hintStyle: TextStyle(
                          color: kHintTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w400),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        size: 20,
                      ),
                      prefixIconColor: kHintTextColor,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: BorderSide(color: kSignInContainerColor),
                        gapPadding: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: BorderSide(color: kSignInContainerColor),
                        gapPadding: 10,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: BorderSide(color: kSignInContainerColor),
                        gapPadding: 10,
                      ),
                    ),
                  ),
                ),
              ),
              //sign in button
              GestureDetector(
                onTap: () {
                  if (mobileController.text.toString().isEmpty) {
                    Fluttertoast.showToast(msg: "Enter Number");
                    return;
                  }
                  _checkUser();
                },
                child: Container(
                  width: width - 68,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: kSignInContainerColor,
                  ),
                  child: Center(
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              //divider
              Padding(
                padding: const EdgeInsets.only(top: 90, bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        color: kHintTextColor,
                      ),
                    ),
                    Text(
                      'Or ',
                      style: TextStyle(
                        color: kDividerColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Expanded(
                      child: Divider(
                        color: kHintTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              //google container
              GestureDetector(
                onTap: () {
                  signup(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: kSignInContainerColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 3,
                        ),
                        Image.asset(
                          'assets/icons/google.png',
                          height: 25,
                          width: 25,
                          fit: BoxFit.fill,
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Text(
                          'Continue with google',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              //facebook
              GestureDetector(
                onTap: () {
                  signInWithFacebook(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: kSignInContainerColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.facebook,
                          size: 25,
                          color: Colors.blue.shade900,
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Text(
                          'Continue with facebook',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //bottom label
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 67),
                child: RichText(
                  text: TextSpan(
                      text: 'Don’t have an account?',
                      style: TextStyle(
                        color: kLoadingScreenTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(
                          text: ' Sign Up',
                          style: TextStyle(
                            color: kSignInBottomLabelColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginSignUpScreen(
                                            loginState: false)),
                                  ),
                                },
                        ),
                      ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
}
