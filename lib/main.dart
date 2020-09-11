import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fu_za_mobile_application/body.dart';
import 'package:splashscreen/splashscreen.dart';

void main() => runApp(Intro());

class Intro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FuZaStatefulWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class IntroState extends StatefulWidget {
  @override
  IntroStateWidget createState() => IntroStateWidget();
}

class IntroStateWidget extends State<IntroState> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 6,
      navigateAfterSeconds: new FuZaStatefulWidget(),
      title: new Text(
        'Welcome to Fu-Za Learning',
        textScaleFactor: 2,
      ),
      image: new Image.asset('assets/splash.png'),
      loadingText: Text("Loading"),
      photoSize: 100.0,
      loaderColor: Colors.blue,
    );
  }
}
