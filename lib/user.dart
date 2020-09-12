class User {
  final String companyName;
  final String registeredCourses;
  final String cellNumber;
  final String date;

  User({this.companyName, this.registeredCourses, this.cellNumber, this.date});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      companyName: json['companyName'],
      registeredCourses: json['registeredCourses'],
      cellNumber: json['cellNumber'],
      date: DateTime.now().toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'registeredCourses': registeredCourses,
      'cellNumber': cellNumber,
      'date': DateTime.now().toString(),
    };
  }

  @override
  String toString() {
    return 'User{companyName: $companyName, registeredCourses: $registeredCourses, cellNumber: $cellNumber, date: $date}';
  }
}
