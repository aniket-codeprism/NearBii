import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/authentication/signin_screen.dart';

class AuthenticationMainPage extends StatelessWidget {
  const AuthenticationMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Image Section
            Container(
              width: width - 78,
              height: width - 78,
              decoration: BoxDecoration(
                border: Border.all(color: kCircleBorderColor),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: kCircleBorderColor),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Container(
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage(
                          'assets/images/authentication/authentication_main_page_image.png',
                        ),
                        fit: BoxFit.fill,
                      )),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 47,
            ),
            //welcome label
            Text(
              'Hi, welcome to',
              style: TextStyle(
                color: kLoadingScreenTextColor,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            //nearbii logo
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 37),
              child: Container(
                height: 60,
                width: 350,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage(
                    'assets/images/authentication/logo.png',
                  ),
                  fit: BoxFit.fill,
                )),
              ),
            ),
            //authentication column
            Column(
              children: [
                //sign in
                GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginSignUpScreen(
                        loginState: true,
                      ),
                    ),
                  ),
                  child: Container(
                    width: width - 68,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: kSignInContainerColor,
                    ),
                    child: const Center(
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
                const SizedBox(
                  height: 25,
                ),
                //sign up
                GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          const LoginSignUpScreen(loginState: false),
                    ),
                  ),
                  child: Container(
                    width: width - 68,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: kSignUpContainerColor,
                    ),
                    child: Center(
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: kLoadingScreenTextColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
