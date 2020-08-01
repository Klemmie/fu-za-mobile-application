import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fu_za_mobile_application/user.dart';
import 'package:fu_za_mobile_application/video.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_number/mobile_number.dart';
import 'package:path_provider/path_provider.dart';

import 'db.dart';

class Downloader {
  Future<User> getUserDetails() async {
    User user = await DatabaseHelper().user();

    if (user != null) {
      return user;
    } else {
      String cellNumber = await initMobileNumberState();

      final response = await http
          .get('http://turtletech.ddns.me:100/fu-za/userDetails/' + cellNumber);

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
    List<int> nums = new List();
    for (Video video in videos) {
      nums.add(video.vidOrder);
    }
    if (nums != null && nums.isNotEmpty) {
      nums.sort();

      List<Video> returnVideos = new List();
      for (int videoOrder in nums) {
        for (Video video in videos) {
          if (video.vidOrder == videoOrder) returnVideos.add(video);
        }
      }

      return returnVideos;
    }
    return videos;
  }

  Future<List<Video>> getVideoListServer(String course, String level) async {
    User user = await getUserDetails();
    String cellNumber = user.cellNumber;

    final response = await http.get(
        'http://turtletech.ddns.me:100/fu-za/videoList/' +
            course +
            '/' +
            level +
            '/' +
            cellNumber);

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

  void downloadFile(String cellNumber, Video video) async {
    String name = video.name;
    String course = video.course;
    String guid = video.guid;
    String url = 'http://turtletech.ddns.me:100/fu-za/download/' +
        cellNumber +
        '/' +
        guid;
    http.Client _client = new http.Client();
    var req = await _client.get(Uri.parse(url));
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
        level: "1",
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
      return await MobileNumber.mobileNumber;
    } on PlatformException catch (e) {
      debugPrint("Failed to get mobile number because of '${e.message}'");
    }
    return null;
  }

  void videoSync() async {
    User user = await getUserDetails();
    List<Video> local = await getVideoListLocal();

    Video firstVideo;
    if (local.isNotEmpty) firstVideo = local.last;

    int hour = new DateTime.now().hour;
    if (hour >= 6 && hour <= 23) {
      print('Download time baby!');
    } else
      print('Sorry neh...');

    if (firstVideo == null ||
        DateTime.parse(firstVideo.date).difference(DateTime.now()) >=
            new Duration(days: 7))
      for (String course in user.registeredCourses.split(",")) {
        List<Video> videoList = await getVideoListServer(course, "1");

        for (Video download in videoList) {
          int add = 1;
          for (Video deviceVideo in local) {
            if (download.guid.compareTo(deviceVideo.guid) == 0) {
              add = 0;
            }
          }

          if (add == 1) {
            downloadFile(user.cellNumber, download);
            break;
          }
        }
      }

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
    final response = await http.post(
        'http://turtletech.ddns.me:100/fu-za/addWatched/' +
            cellNumber +
            '/' +
            deviceVideo.guid +
            '/true');

    if (response.statusCode == 201) {
      print(
          'Added to watched:' + deviceVideo.guid + ' list for: ' + cellNumber);
      Video watchedVideo = new Video(
          vidOrder: deviceVideo.vidOrder,
          name: deviceVideo.name,
          course: deviceVideo.course,
          level: deviceVideo.level,
          guid: deviceVideo.guid,
          watched: "synced",
          path: deviceVideo.path,
          date: deviceVideo.date);
      DatabaseHelper().updateVideo(watchedVideo);
    } else {
      throw Exception('Failed to update watched video');
    }
  }
}
