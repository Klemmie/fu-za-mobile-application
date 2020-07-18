import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fu_za_mobile_application/user.dart';
import 'package:fu_za_mobile_application/video.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class Downloader {
  Future<Video> fetchVideo(Video video) async {
    User userDetails = getUserDetails() as User;
    var courses = userDetails.registeredCourses.split(',');
    for (var course in courses) {
      createDirectory(course);
    }

    //Video List call
    final response = await http
        .get('http://turtletech.ddns.me:100/fu-za/videoList/test/1/0737224748');

    if (response.statusCode == 200) {
      print(response.body);
    }
  }

  void createDirectory(String dirName) async {
    String dir = (await getTemporaryDirectory()).path;
    new Directory(dir + "/" + dirName)
        .create(recursive: true)
        .then((Directory directory) {
      print(directory.path);
    });
  }

  Future<User> getUserDetails() async {
    //TODO get cell number from device
    final response = await http
        .get('http://turtletech.ddns.me:100/fu-za/userDetails/0737224748');

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get user details');
    }
  }

  void download(String url) {
    _downloadFile(url, "test", "Jy bly stil");
  }

  static Future<File> _downloadFile(
      String url, String course, String name) async {
    print(url);
    http.Client _client = new http.Client();
    var req = await _client.get(Uri.parse(url));
    var bytes = req.bodyBytes;
    String dir = (await getTemporaryDirectory()).path;
    new Directory('$dir/$course')
        .create(recursive: true)
        .then((Directory directory) async {
      File file = new File('$dir/$course/$name.mp4');
      await file.writeAsBytes(bytes);
      print('File size:${await file.length()}');
      print(file.path);
      return file;
    });
  }
}
