import 'dart:io';

import 'package:puppeteer/puppeteer.dart';

/// Takes a screenshot of the given page and save as [name].png under screenshots.
Future screenshot(Page page, String name) async {
  await page.screenshot().then((data) {
    return File('./.screenshots/$name.png').create().then((file) {
      return file.writeAsBytes(data);
    });
  });
}

mixin Diagnostics {
  String get contextHint;

  void warn(String msg) {
    print('[Warning - $contextHint] $msg');
  }

  void info(String msg) {
    print('[Info - $contextHint] $msg');
  }

  void error(String msg, {bool fatal = false}) {
    print('[Error - $contextHint] $msg');
    if (fatal) {
      throw msg;
    }
  }
}