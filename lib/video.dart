class Video {
  final String name;
  final String course;
  final String level;
  final String guid;

  Video({this.name, this.course, this.level, this.guid});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      name: json['name'],
      course: json['course'],
      level: json['level'],
      guid: json['guid'],
    );
  }
}
