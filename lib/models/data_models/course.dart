import 'package:flutter/foundation.dart';

class Course {
  String subjectCode;
  int courseCode;
  int crn;
  String section;
  String level;
  String title;
  double credits;
  String gradeMode;
  DateTime dateLastUpdated;
  String actionId;
  List<String> instructors;
  String registrationStatus;

  Course(
      {@required this.crn,
      this.actionId,
      this.registrationStatus,
      this.subjectCode,
      this.courseCode,
      this.section,
      this.level,
      this.title,
      this.credits,
      this.gradeMode,
      this.dateLastUpdated,
      this.instructors});

  @override
  String toString() {
    return '<$crn> $subjectCode $courseCode ($section)\t$registrationStatus\t\t"$title"';
  }
}

abstract class RegistrationStatus {
  static const String registered = 'Registered';
  static const String waitListed = 'Wait-listed';
}

abstract class GradeMode {
  static const String letterGrade = 'Letter Grade';
  static const String passFail = 'Pass/Fail';
  static const String audit = 'Audit';
}
