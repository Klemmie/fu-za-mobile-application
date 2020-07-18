import 'package:flutter/material.dart';
import 'package:fu_za_mobile_application/videoplayer.dart';

import 'downloader.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var downloader = new Downloader();
    downloader.download(
        "http://turtletech.ddns.me:100/fu-za/download/0737224748/a797eea9-f471-439d-a7f0-42bec9871124");
    return MaterialApp(
      title: 'Welcome to Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirstScreen(),
    );
  }
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    VideoPlayerApp videoPlayerApp = new VideoPlayerApp();
    return Scaffold(
      appBar: AppBar(
        title: Text('First Screen'),
      ),
      body: Center(
        child: RaisedButton(
          color: Colors.red,
          child: Text('Go to Second Screen'),
          onPressed: () {
            //Use`Navigator` widget to push the second screen to out stack of screens
            Navigator.of(context)
                .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
              return videoPlayerApp.build(context);
            }));
          },
        ),
      ),
    );
  }
}
