import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:vansales/capitalize.dart';
import 'package:vansales/screen/profile_setup_screen.dart';
import 'package:vansales/utils.dart';

import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({Key? key}) : super(key: key);

  @override
  _SplashScreen1State createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1> {
  @override
  void initState() {
    super.initState();
    _navigatetoscreen2();
  }

  _navigatetoscreen2() async {
    await Future.delayed(const Duration(milliseconds: 1000), () {});
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const SplashScreen2()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Color(0xfff7f6fb),
        ),
        child: Stack(children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: Hero(
                tag: 'splashcon',
                child: Container(
                  width: 220,
                  height: 220,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.indigoAccent,
                    borderRadius: BorderRadius.circular(110),
                  ),
                  child: const Text(
                    'VanSale',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontFamily: 'Baumans',
                        fontSize: 39,
                        letterSpacing: 0,
                        fontWeight: FontWeight.normal,
                        height: 1),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Version 1.0.5',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  'Release 25-07-22',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class SplashScreen2 extends StatefulWidget {
  const SplashScreen2({Key? key}) : super(key: key);

  @override
  State<SplashScreen2> createState() => _SplashScreen2State();
}

class _SplashScreen2State extends State<SplashScreen2> {
  late FirebaseAuth _auth;
  late User? _user;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _user = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'splashcon',
      child: AnimatedSplashScreen(
          duration: 1000,
          splash: Text(
            _user == null ? 'Join us to Continue...' : 'Lets sell the products',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Color.fromRGBO(255, 255, 255, 1),
                fontFamily: 'Baumans',
                fontSize: 30,
                letterSpacing: 0,
                fontWeight: FontWeight.normal,
                height: 1),
          ),
          nextScreen: _user == null
              ? const LoginScreen()
              : Preferences.getPData()
                  ? const MainScreen()
                  : const ProfileSetupScreen(isUpdate: false),
          splashTransition: SplashTransition.fadeTransition,
          pageTransitionType: PageTransitionType.rightToLeft,
          backgroundColor: Colors.indigoAccent),
    );
  }
}
