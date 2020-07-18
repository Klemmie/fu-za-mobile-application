import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fu_za_mobile_application/user.dart';
import 'package:fu_za_mobile_application/video.dart';
import 'package:http/http.dart' as http;

Future<Video> fetchVideo(Video video) async {
  User userDetails = getUserDetails() as User;
  var courses = userDetails.registeredCourses.split(',');
  for (var course in courses) {

  }

  final response = await http
      .get('http://turtletech.ddns.me:100/fu-za/videoList/test/1/0737224748');

  if (response.statusCode == 200) {
    print(response.body);
  }
}

void createDirectory(String dirName) {
  new Directory('fu-za/' + dirName)
      .create(recursive: true)
      .then((Directory directory) {
    print(directory.path);
  });
}

void getDirectory() {
  var systemTempDir = Directory.systemTemp;

  systemTempDir
      .list(recursive: true, followLinks: false)
      .listen((FileSystemEntity entity) {
    print(entity.path);
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
