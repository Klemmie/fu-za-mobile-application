class User {
  final String companyName;
  final String registeredCourses;

  User({this.companyName, this.registeredCourses});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      companyName: json['companyName'],
      registeredCourses: json['registeredCourses'],
    );
  }
}