import 'package:flutter_test/flutter_test.dart';
import 'package:oscar/models/buzzport.dart';
import 'package:oscar/models/data_models/course.dart';
import 'package:oscar/models/data_models/credential.dart';
import 'package:oscar/models/oscar.dart';
import 'package:oscar/models/utils.dart';
import 'package:puppeteer/puppeteer.dart';

void main() async {
  final _credential = await Credential.load();

  test('Test Oscar Registration', () async {
    // Instantiate browser & open a new tab
    // If local chromium not downloaded, remove parameter executablePath to automatically
    // download chromium binary when test is run.
    var browser = await puppeteer.launch(
        executablePath:
            '.local-chromium/768783/chrome-mac/Chromium.app/Contents/MacOS/Chromium');

    // Login to Buzzport
    var buzzport = Buzzport(browser, _credential);
    await buzzport.loginIfNeeded();

    // Use Buzzport to login to Oscar
    var oscar = buzzport.oscar();
    await oscar.init().then((page) {
      return screenshot(page, 'registration');
    });

    // Select most recent term
    await oscar.getTerms().then((terms) {
      print('Terms:\n$terms');
      print('Selecting most recent term - ${terms.first}');
      return oscar.selectTerm(terms.first);
    });

    // Test get current schedule
    await oscar.getCurrentSchedule().then(Oscar.printSchedule);

    // Test register new courses
    await oscar.registerCourses([
      Course(crn: 87912),
      Course(crn: 90017),
      Course(crn: 81337),
      Course(crn: 91690),
    ]).then(Oscar.printSchedule);

    await browser.close();
  });
}
