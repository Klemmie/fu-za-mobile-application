import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fu_za_mobile_application/video.dart';
import 'package:fu_za_mobile_application/videoplayer.dart';

import 'downloader.dart';

class FuZa extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
//      home: IntroState(),
      home: FuZaStatefulWidget(),
    );
  }
}

class FuZaStatefulWidget extends StatefulWidget {
  FuZaStatefulWidget({Key key}) : super(key: key);

  @override
  FuZaStatefulWidgetState createState() => FuZaStatefulWidgetState();
}

class FuZaStatefulWidgetState extends State<FuZaStatefulWidget> {
  Future<List<Video>> videos;
  Timer timer;

  @override
  void initState() {
    super.initState();

    fetchVideos();
    timer = Timer.periodic(Duration(seconds: 600), (Timer t) => fetchVideos());
  }

  void fetchVideos() async {
    syncServerVideo();
    setState(() {
      videos = Downloader().getVideoListLocal();
    });
  }

  void syncServerVideo() async {
    Downloader().videoSync();
  }

  Future<void> _fetchVideos() async {
    setState(() {
      fetchVideos();
    });
  }

  List<Widget> videoList(List<Video> videos) {
    List<String> courses = new List();
    for (Video video in videos) {
      if (!courses.contains(video.course)) {
        courses.add(video.course);
      }
    }
    List<Widget> vids = new List();
    List<Widget> returns = new List();
    Widget linkList;
    for (String course in courses) {
      for (Video video in videos) {
        if (video.course == course) {
          linkList = ExpansionTile(
              leading: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
              ),
              title: Text(
                video.name,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                textAlign: TextAlign.left,
              ),
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Spacer(),
                      Spacer(),
                      Column(
                        children: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          VideoPlayerApp(video: video)
                                              .build(context)));
                            },
                            textColor: Color.fromRGBO(255, 102, 0, 1),
                            child: new Text(
                              'Play video',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 15),
                              textAlign: TextAlign.left,
                            ),
                            color: Color.fromRGBO(204, 0, 0, 0.3),
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                          ),
                        ],
                      ),
                      Icon(
                        Icons.play_arrow,
                        color: Color.fromRGBO(255, 102, 0, 1),
                      ),
                      Spacer(),
                      Column(children: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Downloader().downloadPdf(video.guid, video.name);
                          },
                          textColor: Color.fromRGBO(255, 102, 0, 1),
                          child: new Text(
                            'Download material',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 15),
                            textAlign: TextAlign.right,
                          ),
                          color: Color.fromRGBO(204, 0, 0, 0.3),
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                        ),
                      ]),
                      Icon(
                        Icons.file_download,
                        color: Color.fromRGBO(255, 102, 0, 1),
                      ),
                      Spacer(),
                    ])
              ]);
//          vids.add(Divider(thickness: 1, height: 0, indent: 20, endIndent: 0, color: Colors.transparent));
          vids.add(linkList);
//          vids.add(Divider(thickness: 1, height: 0, indent: 20, endIndent: 0, color: Colors.transparent));
        }
      }

      Widget catList = ExpansionTile(
        children: vids,
        title: new Text(
          course,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
        ),
        backgroundColor: Color.fromRGBO(51, 153, 102, 0.9),
      );
      returns.add(catList);
      vids = new List();
    }

    return returns;
  }

  @override
  Widget build(BuildContext context) {
    Widget titleSection = Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Fu-Za Learning',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(0, 51, 153, 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          /*3*/
          Icon(
            Icons.star,
            color: Color.fromRGBO(255, 102, 0, 1),
          ),
        ],
      ),
    );

    return MaterialApp(
        title: 'Fu-Za Learning',
        home: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/real-background.png"),
                  fit: BoxFit.cover)),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: titleSection,
              backgroundColor: Color.fromRGBO(51, 153, 102, 1),
            ),
            //removed
            body: FutureBuilder<List<Video>>(
                future: videos,
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? RefreshIndicator(
                          child: ListView(
                            children: videoList(snapshot.data),
                          ),
                          onRefresh: _fetchVideos,
                        )
                      : Center(
                          child: CircularProgressIndicator(),
                        );
                }),
          ),
        ));
  }
}