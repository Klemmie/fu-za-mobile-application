import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fu_za_mobile_application/user.dart';
import 'package:fu_za_mobile_application/video.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:path_provider/path_provider.dart';

import 'db.dart';

class Downloader {
  Future<User> getUserDetails() async {
    User user = await DatabaseHelper().user();

    if (user != null) {
      if (DateTime.parse(user.date).difference(DateTime.now()) >=
          new Duration(days: 1)) {
        final response = await sendRequestToServer(
            'get', 'user/userDetails/' + user.cellNumber);

        if (response.statusCode == 200) {
          User updateUser = User.fromJson(json.decode(response.body));
          await DatabaseHelper().updateUser(updateUser);
          return updateUser;
        } else {
          throw Exception('Failed to get user details');
        }
      }
      return user;
    } else {
      String cellNumber = await initMobileNumberState();

      final response =
          await sendRequestToServer('get', 'user/userDetails/' + cellNumber);

      if (response.statusCode == 200) {
        User newUser = User.fromJson(json.decode(response.body));
        await DatabaseHelper().insertUser(newUser);
        return newUser;
      } else {
        throw Exception('Failed to get user details');
      }
    }
  }

  Future<List<Video>> getVideoListLocal() async {
    List videos = await DatabaseHelper().video();
    List<String> course = new List();
    List<Video> returnVideos = new List();

    for (Video courseVids in videos) {
      if (!course.contains(courseVids.course)) course.add(courseVids.course);
    }
    for (String courseName in course) {
      List<int> nums = new List();
      for (Video video in videos) {
        if (video.course == courseName) nums.add(video.vidOrder);
      }
      if (nums != null && nums.isNotEmpty) {
        nums.sort();

        for (int videoOrder in nums) {
          for (Video video in videos) {
            if (video.course == courseName) {
              if (video.vidOrder == videoOrder) {
                returnVideos.add(video);
              }
            }
          }
        }
      }
    }
    return returnVideos;
  }

  Future<List<Video>> getVideoListServer(String course) async {
    User user = await getUserDetails();
    String cellNumber = user.cellNumber;

    final response = await sendRequestToServer(
        'get', 'video/videoList/' + course + '/' + cellNumber);

    if (response.statusCode == 200) {
      List<Video> videos = List();
      List videosReturned = jsonDecode(response.body);
      for (var video in videosReturned) {
        videos.add(Video.fromJson(json.decode(jsonEncode(video))));
      }
      return videos;
    } else {
      throw Exception('Failed to get user details');
    }
  }

  void downloadVideo(String cellNumber, Video video) async {
    String name = video.name;
    String course = video.course;
    String guid = video.guid;
    var req = await sendRequestToServer(
        'get', 'mobile/download/' + cellNumber + '/' + guid);
    var bytes = req.bodyBytes;
    String dir = (await getApplicationDocumentsDirectory()).path;
    if (new Directory('$dir/$course').existsSync()) {
      File file = new File('$dir/$course/$name.mp4');
      await file.writeAsBytes(bytes);
    } else {
      new Directory('$dir/$course')
          .create(recursive: true)
          .then((Directory directory) async {
        File file = new File('$dir/$course/$name.mp4');
        await file.writeAsBytes(bytes);
      });
    }

    Video insertedVideo = new Video(
        vidOrder: video.vidOrder,
        name: name,
        course: course,
        guid: guid,
        watched: "false",
        path: '$dir/$course/$name.mp4',
        date: DateTime.now().toString());
    await DatabaseHelper().insertVideo(insertedVideo);
  }

  Future<String> initMobileNumberState() async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return null;
    }

    try {
      List<SimCard> simCards = await MobileNumber.getSimCards;
      String mobileNumber = "";
      for (SimCard simCard in simCards) {
        if (simCard.number != null) {
          mobileNumber = simCard.number;
          break;
        }
      }
      return mobileNumber;
    } on PlatformException catch (e) {
      debugPrint("Failed to get mobile number because of '${e.message}'");
    }
    return null;
  }

  void videoSync() async {
    User user = await getUserDetails();
    List<Video> local = await getVideoListLocal();

    int hour = new DateTime.now().hour;
    if (hour <= 18 || hour >= 23) {
      for (String course in user.registeredCourses.split(",")) {
        Video firstVideo;
        for (Video lcVid in local) {
          if (lcVid.course == course) {
            if (firstVideo == null ||
                DateTime.parse(firstVideo.date)
                    .isBefore(DateTime.parse(lcVid.date))) {
              firstVideo = lcVid;
            }
          }
        }

        if (firstVideo == null ||
            DateTime.parse(firstVideo.date).difference(DateTime.now()) >=
                new Duration(days: 7)) {
          List<Video> videoList = await getVideoListServer(course);

          for (Video download in videoList) {
            int add = 1;
            for (Video deviceVideo in local) {
              if (download.guid.compareTo(deviceVideo.guid) == 0) {
                add = 0;
              }
            }

            if (add == 1) {
              downloadVideo(user.cellNumber, download);
              break;
            }
          }
        }
      }
    } else
      print('Sorry neh...');

    for (Video deviceVideo in local) {
      if (DateTime.parse(deviceVideo.date).difference(DateTime.now()) >
          new Duration(days: 14)) {
        Directory(deviceVideo.path).deleteSync(recursive: true);
        await DatabaseHelper().deleteVideo(deviceVideo.guid);
      } else
        print('Not old enough to delete');
    }

    for (Video deviceVideo in local) {
      if (deviceVideo.watched == "true") {
        updateWatched(deviceVideo, user.cellNumber);
      }
    }
  }

  void updateWatched(Video deviceVideo, String cellNumber) async {
    final response = await sendRequestToServer(
        'post',
        'watched/addWatched/' +
            cellNumber +
            '/' +
            deviceVideo.guid +
            '/true/' +
            DateTime.now().toIso8601String());

    if (response.statusCode == 201) {
      Video watchedVideo = new Video(
          vidOrder: deviceVideo.vidOrder,
          name: deviceVideo.name,
          course: deviceVideo.course,
          guid: deviceVideo.guid,
          watched: "synced",
          path: deviceVideo.path,
          date: deviceVideo.date);
      DatabaseHelper().updateVideo(watchedVideo);
    } else {
      throw Exception('Failed to update watched video');
    }
  }

  Future<http.Response> sendRequestToServer(String reqType, String url) async {
    bool trustSelfSigned = true;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = new IOClient(httpClient);
    var response;
    if (reqType == 'post') {
      response = await ioClient.post("https://turtletech.ddns.me:100/$url");
    } else {
      response = await ioClient.get("https://turtletech.ddns.me:100/$url");
    }

    return response;
  }
}
