class User {
  final String companyName;
  final String registeredCourses;
  final String cellNumber;

  User({this.companyName, this.registeredCourses, this.cellNumber});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      companyName: json['companyName'],
      registeredCourses: json['registeredCourses'],
      cellNumber: json['cellNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'registeredCourses': registeredCourses,
      'cellNumber': cellNumber,
    };
  }

  @override
  String toString() {
    return 'User{companyName: $companyName, registeredCourses: $registeredCourses, cellNumber: $cellNumber}';
  }
}
