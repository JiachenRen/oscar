import 'package:flutter_test/flutter_test.dart';
import 'package:oscar/models/buzzport.dart';
import 'package:oscar/models/data_models/credential.dart';
import 'package:oscar/models/utils.dart';
import 'package:puppeteer/puppeteer.dart';

void main() async {
  final _credential = await Credential.load();

  test('Test Buzzport Login', () async {
    // Instantiate browser & open a new tab
    var browser = await puppeteer.launch(
        executablePath:
            '.local-chromium/768783/chrome-mac/Chromium.app/Contents/MacOS/Chromium');

    // Login
    await Buzzport(browser, _credential).loginIfNeeded();

    await browser.close();
  });
}
