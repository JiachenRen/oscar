import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:puppeteer/puppeteer.dart';

void main() async {
  test('Test Puppeteer', () async {
    // Download the Chromium binaries, launch it and connect to the "DevTools"
    var browser = await puppeteer.launch();

    // Open a new tab
    var myPage = await browser.newPage();

    // Go to a page and wait to be fully loaded
    await myPage.goto('https://www.github.com', wait: Until.networkIdle);

    // Do something... See other examples
    await myPage.screenshot().then((data) {
      return File('./.screenshots/github.png').create().then((file) {
        return file.writeAsBytes(data);
      });
    });
    assert(await myPage.evaluate('() => document.title') ==
        'The world’s leading software development platform · GitHub');

    // Gracefully close the browser's process
    await browser.close();
  });
}
