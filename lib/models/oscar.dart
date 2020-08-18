import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:oscar/models/data_models/course.dart';
import 'package:oscar/models/data_models/term.dart';
import 'package:oscar/models/utils.dart';
import 'package:puppeteer/puppeteer.dart';

class Oscar with Diagnostics {
  final Browser _browser;

  final String url;

  final String _registrationUrl =
      'https://oscar.gatech.edu/pls/bprod/twbkwbis.P_GenMenu?name=bmenu.P_RegMnu';

  final String _selectTermUrl =
      'https://oscar.gatech.edu/pls/bprod/bwskflib.P_SelDefTerm';

  final String _addDropClassUrl =
      'https://oscar.gatech.edu/pls/bprod/bwskfreg.P_AltPin';

  Page page;

  Oscar(this._browser, this.url);

  /// Logins into Oscar using link provided by buzzport.
  Future<Page> init() async {
    info('creating new page for Oscar');
    page = await _browser.newPage();
    info('visiting Oscar');
    await page.goto(url, wait: Until.networkIdle);
    info('navigating to registration');
    await page.goto(_registrationUrl);
    info('initialized');
    return page;
  }

  /// Selects current term (semester)
  Future<Page> selectTerm(Term term) async {
    info('navigating to terms');
    await page.goto(_selectTermUrl, wait: Until.networkIdle);
    info('selecting $term');
    await page.select('#term_id', [term.optionValue]);
    info('submitting changes');
    await page.clickAndWaitForNavigation('input[type=submit][value=Submit]');
    info('term set to $term');
    return page;
  }

  /// Fetches list of editable terms (semesters)
  Future<List<Term>> getTerms() async {
    info('navigating to terms');
    await page.goto(_selectTermUrl, wait: Until.networkIdle);
    return page.content.then(parse).then((doc) {
      return doc.querySelectorAll('#term_id > option').map((option) {
        return Term(option.attributes['value'], option.text);
      }).where((term) {
        return !term.name.contains('View only');
      }).toList();
    });
  }

  /// Registers the given [courses]. Each [Course] instance only needs
  /// to have the CRN field.
  ///
  /// Returns students' updated schedule as a list of registered/wait-listed courses.
  Future<List<Course>> registerCourses(List<Course> courses) async {
    info('navigating to add/drop class');
    if (courses.length > 10) {
      error('maximum of 10 courses can be registered at one time');
    }
    await page.goto(_addDropClassUrl, wait: Until.networkIdle);
    info('entering course CRNs...');
    var id = 1;
    for (var course in courses) {
      info('adding <${course.crn}>');
      await page.type('#crn_id$id', '${course.crn}');
      id++;
    }
    info('submitting changes...');
    await page.clickAndWaitForNavigation('input[name=REG_BTN][type=submit]');
    // Todo: check registration errors & status
    await screenshot(page, 'add_classes${courses.map((i) => i.crn).toList()}');
    return page.content
        .then(parse)
        .then(_parseCurrentSchedule);
  }

  /// Fetches current student schedule (including registered/wait-listed info)
  Future<List<Course>> getCurrentSchedule() async {
    info('navigating to add/drop class');
    await page.goto(_addDropClassUrl, wait: Until.networkIdle);
    return page.content.then(parse).then(_parseCurrentSchedule);
  }

  List<Course> _parseCurrentSchedule(Document doc) {
    var rows = doc.querySelectorAll('table.datadisplaytable[summary="Current Schedule"] > tbody > tr');
    // Remove table header
    rows.removeAt(0);
    return rows.map(_parseCourseFromScheduleRow).toList();
  }

  Course _parseCourseFromScheduleRow(Element element) {
    final columns = element.querySelectorAll('td');
    final registrationStatus = columns[0].text.contains('Registered')
        ? RegistrationStatus.registered
        : (columns[0].text.contains('Wait Listed')
        ? RegistrationStatus.waitListed
        : columns[0].text);
    return Course(crn: int.parse(columns[2].text.trim()))
      ..registrationStatus = registrationStatus
      ..actionId = columns[1]
          .querySelector('select')
          .attributes['id']
      ..subjectCode = columns[3].text.trim()
      ..courseCode = int.parse(columns[4].text.trim())
      ..section = columns[5].text.trim()
      ..level = columns[6].text.trim()
      ..credits = double.parse(columns[7].text.trim())
      ..gradeMode = columns[8].text.trim()
      ..title = columns[9].text.trim();
  }

  static void printSchedule(List<Course> courses) {
    print('Schedule:\n');
    print('> Registered');
    courses
        .where((course) =>
    course.registrationStatus == RegistrationStatus.registered)
        .forEach((course) {
      print(course);
    });
    print('\n');
    print('> Wait-listed');
    courses
        .where((course) =>
    course.registrationStatus == RegistrationStatus.waitListed)
        .forEach((course) {
      print(course);
    });
  }

  @override
  String contextHint = 'Oscar';
}
