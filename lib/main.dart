import 'package:flutter/material.dart';

import 'downloader.dart';
import 'videoplayer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    VideoPlayerApp videoPlayer = new VideoPlayerApp();
    return videoPlayer.build(context);
  }
}
