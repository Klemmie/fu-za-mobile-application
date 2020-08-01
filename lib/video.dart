class Video {
  final int vidOrder;
  final String name;
  final String course;
  final String level;
  final String guid;
  final String watched;
  final String path;
  final String date;

  Video(
      {this.vidOrder, this.name, this.course, this.level, this.guid, this.watched, this.path, this.date});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      vidOrder: json['vidOrder'],
      name: json['name'],
      course: json['course'],
      level: json['level'],
      guid: json['guid'],
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'vidOrder': vidOrder,
      'name': name,
      'course': course,
      'level': level,
      'guid': guid,
      'watched': watched,
      'path': path,
      'date': date,
    };

    return map;
  }

  @override
  String toString() {
    return 'Video{vidOrder: $vidOrder, name: $name, course: $course, level: $level,'
        ' guid: $guid, watched: $watched, path: $path, date: $date}';
  }
}
