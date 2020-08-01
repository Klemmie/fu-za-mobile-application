import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fu_za_mobile_application/video.dart';
import 'package:fu_za_mobile_application/videoplayer.dart';

import 'downloader.dart';

void main() {
  runApp(MaterialApp(
    title: 'Navigation Basics',
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
//  Widget build(BuildContext context) {
//    Downloader().videoSync();
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Welcome to Flutter'),
//      ),
//      body: new Center(
//        child: new ButtonBar(
//          mainAxisSize: MainAxisSize.min,
//          children: <Widget>[
//            new RaisedButton(
//              child: new Text('Play hardcoded video'),
//              onPressed: () {
//                Navigator.push(context,
//                    MaterialPageRoute(builder: (context) => FirstScreen()));
//              },
//            ),
//            new RaisedButton(
//              child: new Text('Video List'),
//              onPressed: () {
//                VideoList();
//              },
//            ),
//          ],
//        ),
//      ),
//    );
//
//    return FutureBuilder<List<Video>>(
//        future: Downloader().getVideoListLocal(),
//        builder: (context, snapshot) {
//          if (snapshot.hasData) {
//            print("Has data");
//            ListView.builder(
//                itemCount: snapshot.data.length,
//                itemBuilder: (BuildContext context, int index) {
//                  return Container(
//                    height: 50,
//                    child: Center(
//                      child: Text('Name: ' + snapshot.data[index].name),
//                    ),
//                  );
//                });
//          } else {
//            return Center(
//              child: CircularProgressIndicator(),
//            );
//          }
//        });
//  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  MyStatefulWidgetState createState() => MyStatefulWidgetState();
}

class MyStatefulWidgetState extends State<MyStatefulWidget> {
  Future<List<Video>> videos;
  Timer timer;

  @override
  void initState() {
    super.initState();

    fetchVideos();

    timer = Timer.periodic(Duration(seconds: 600), (Timer t) => fetchVideos());
  }

  void fetchVideos() async {
    print('fetch videos');
    syncServerVideo();
    setState(() {
      videos = Downloader().getVideoListLocal();
    });
  }

  void syncServerVideo() async {
    Downloader().videoSync();
  }

  Future<void> _fetchVideos() async{
    setState(() {
      fetchVideos();
    });
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
                    'Fu-Za',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Learning',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          /*3*/
          Icon(
            Icons.star,
            color: Colors.red[500],
          ),
          Text('41'),
        ],
      ),
    );

    Color color = Theme.of(context).primaryColor;

    Widget buttonSection = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(color, Icons.call, 'CALL'),
          _buildButtonColumn(color, Icons.near_me, 'ROUTE'),
          _buildButtonColumn(color, Icons.share, 'SHARE'),
        ],
      ),
    );

    Widget textSection = Container(
        padding: const EdgeInsets.all(32),
        child: FutureBuilder<List<Video>>(
            future: Downloader().getVideoListLocal(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              List<Widget> children;

              if (snapshot.hasData) {
                children = <Widget>[
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 60,
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Text('Name: ' + snapshot.data[index].name);
                        }),
                  )
                ];
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: children,
                ),
              );
            }));

    return MaterialApp(
        title: 'Flutter layout demo',
        home: Scaffold(
          appBar: AppBar(
            title: Text('Flutter layout demo'),
          ),
          //removed
          body: FutureBuilder<List<Video>>(
            future: videos,
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? RefreshIndicator(
                      child: ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (_, int position) {
                            final item = snapshot.data[position];
                            return new GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              VideoPlayerApp(video: item)
                                                  .build(context)));
                                },
                                child: new Column(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: 15.0, right: 15.0),
                                      child: new Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          new Container(
                                            child: Text(
                                              item.name,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(fontSize: 30),
                                              maxLines: 1,
                                            ),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10.0),
                                                    topRight:
                                                        Radius.circular(10.0))),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: 15.0, right: 15.0, top: 0.0),
                                      child: Container(
                                        color: Colors.white,
                                        height: 1.0,
                                      ),
                                    ),
                                  ],
                                ));
                          }),
                onRefresh: _fetchVideos,
              )
                  : Center(
                      child: CircularProgressIndicator(),
                    );
            },
          ),
        ));
  }

  Column _buildButtonColumn(Color color, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
