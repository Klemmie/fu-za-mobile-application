import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fu_za_mobile_application/body.dart';
import 'package:splashscreen/splashscreen.dart';

void main() => runApp(Intro());

class Intro extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
//      home: IntroState(),
      home: IntroState(),
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
    return new SplashScreen(
        seconds: 14,
        navigateAfterSeconds: FuZaStatefulWidget(),
        title: new Text(
          'Welcome to Fu-Za Learning',
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        image: Image.asset("assets/splash.png"),
        backgroundColor: Color.fromRGBO(51, 153, 102, 0.9),
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        onClick: () => FuZaStatefulWidget(),
        loaderColor: Colors.red);
  }
}
