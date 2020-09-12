import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:fu_za_mobile_application/body.dart';
import 'package:fu_za_mobile_application/db.dart';
import 'package:fu_za_mobile_application/video.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(VideoPlayerApp());

class VideoPlayerApp extends StatelessWidget {
  final Video video;

  VideoPlayerApp({this.video});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Fu-Za learner ship', home: VideoPlayerScreen(video: video));
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final Video video;

  VideoPlayerScreen({this.video, Key key}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState(video);
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final Video video;
  String title;
  ChewieController _chewieController;
  TargetPlatform _platform;
  VideoPlayerController controller;
  bool firstFull = true;

  _VideoPlayerScreenState(this.video);

  @override
  void initState() {
    super.initState();
    title = video.name;
    String path = video.path;
    File file = new File('$path');

    controller = VideoPlayerController.file(file);

    controller.addListener(checkVideo);

    _chewieController = ChewieController(
      videoPlayerController: controller,
      aspectRatio: 3 / 2,
      autoPlay: true,
      looping: false,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.green,
        handleColor: Colors.purple,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.lightGreen,
      ),
      fullScreenByDefault: true,
      allowMuting: true,
      allowFullScreen: true,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _chewieController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData.light().copyWith(
        platform: _platform ?? Theme.of(context).platform,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Chewie(
                  controller: _chewieController,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkVideo() {
    if (controller.value.position >=
        (controller.value.duration - new Duration(seconds: 5))) {
      Video watchedVideo = new Video(
          vidOrder: video.vidOrder,
          name: video.name,
          course: video.course,
          guid: video.guid,
          watched: (video.watched == "false") ? "true" : video.watched,
          path: video.path,
          date: video.date);
      DatabaseHelper().updateVideo(watchedVideo);
    }

    if (controller.value.position >= controller.value.duration) {
      _chewieController.exitFullScreen();
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => FuZaStatefulWidget()), (route) => false);
    }
  }
}
