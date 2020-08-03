class Video {
  final int vidOrder;
  final String name;
  final String course;
  final String guid;
  final String watched;
  final String path;
  final String date;

  Video(
      {this.vidOrder, this.name, this.course, this.guid, this.watched, this.path, this.date});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      vidOrder: json['vidOrder'],
      name: json['name'],
      course: json['course'],
      guid: json['guid'],
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'vidOrder': vidOrder,
      'name': name,
      'course': course,
      'guid': guid,
      'watched': watched,
      'path': path,
      'date': date,
    };

    return map;
  }

  @override
  String toString() {
    return 'Video{vidOrder: $vidOrder, name: $name, course: $course'
        ' guid: $guid, watched: $watched, path: $path, date: $date}';
  }
}
