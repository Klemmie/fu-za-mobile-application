class Video {
  final String name;
  final String course;
  final String level;
  final String guid;
  final String watched;
  final String path;

  Video(
      {this.name, this.course, this.level, this.guid, this.watched, this.path});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      name: json['name'],
      course: json['course'],
      level: json['level'],
      guid: json['guid'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'course': course,
      'level': level,
      'guid': guid,
      'watched': watched,
      'path': path,
    };
  }

  @override
  String toString() {
    return 'Video{name: $name, course: $course, level: $level,'
        ' guid: $guid, watched: $watched, path: $path}';
  }
}
