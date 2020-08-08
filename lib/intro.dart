import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:fu_za_mobile_application/body.dart';

void main() => runApp(Intro());

class Intro extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
//      home: IntroState(),
    home: FuZaStatefulWidget(),
    );
  }
}

class IntroState extends StatefulWidget {
  @override
  IntroStateWidget createState() => IntroStateWidget();
}

class IntroStateWidget extends State<IntroState> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: () {
          setState(() {
            isOpen = !isOpen;
            print('on tap pressed');
          });
        },
        child: Center(
          child: FlareActor('assets/flutter_flare_new.flr',
              animation:
//              "circle"

                  isOpen ? "actvate" : ""),
        ),
      ),
    );
  }
}
