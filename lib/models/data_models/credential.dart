import 'dart:io';

import 'package:flutter/foundation.dart';

class Credential {
  final String username;

  final String password;

  static const String _filePath = 'user_data/credentials';

  Credential({@required this.username, @required this.password});

  Future save() {
    return File(_filePath).create().then((file) {
      return file.writeAsString('$username\n$password');
    });
  }

  static Future<Credential> load() {
    if (!File(_filePath).existsSync()) {
      throw 'Credential does not exist';
    }
    return File(_filePath).readAsString().then((value) {
      var lines = value.split('\n');
      return Credential(username: lines[0], password: lines[1]);
    });
  }

  @override
  String toString() {
    return 'Credential{username: $username, password: $password}';
  }
}
