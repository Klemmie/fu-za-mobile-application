import 'dart:async';

import 'package:fu_za_mobile_application/user.dart';
import 'package:fu_za_mobile_application/video.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  Future<Database> userConn() async {
    return openDatabase(
      join(await getDatabasesPath(), 'user.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE user(companyName TEXT, registeredCourses TEXT, cellNumber TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<void> insertUser(User user) async {
    final Database db = await userConn();

    await db.insert(
      'user',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User> user() async {
    final Database db = await userConn();

    final List<Map<String, dynamic>> maps = await db.query('user');

    List<User> users = List.generate(maps.length, (i) {
      return User(
        companyName: maps[i]['companyName'],
        registeredCourses: maps[i]['registeredCourses'],
        cellNumber: maps[i]['cellNumber'],
      );
    });
    if (users.isEmpty) {
      return null;
    }
    return users[0];
  }

  Future<Database> vidConn() async {
    return openDatabase(
      join(await getDatabasesPath(), 'vids.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE video(vidOrder INTEGER, name TEXT, course TEXT, guid TEXT, watched TEXT, path TEXT, date TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<void> insertVideo(Video video) async {
    final Database db = await vidConn();
    List list =
        await db.query('video', where: "guid = ?", whereArgs: [video.guid]);
    if (list.isEmpty)
      await db.insert(
        'video',
        video.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
  }

  Future<List<Video>> video() async {
    final Database db = await vidConn();

    final List<Map<String, dynamic>> maps = await db.query('video');

    return List.generate(maps.length, (i) {
      return Video(
        vidOrder: maps[i]['vidOrder'],
        name: maps[i]['name'],
        course: maps[i]['course'],
        guid: maps[i]['guid'],
        watched: maps[i]['watched'],
        path: maps[i]['path'],
        date: maps[i]['date'],
      );
    });
  }

  Future<void> updateVideo(Video video) async {
    final db = await vidConn();

    await db.update(
      'video',
      video.toMap(),
      where: "guid = ?",
      whereArgs: [video.guid],
    );
  }

  Future<void> deleteVideo(String guid) async {
    final db = await vidConn();

    await db.delete(
      'video',
      where: "guid = ?",
      whereArgs: [guid],
    );
  }
}
