import 'dart:async';

import 'package:oscar/models/data_models/credential.dart';
import 'package:oscar/models/oscar.dart';
import 'package:oscar/models/utils.dart';
import 'package:puppeteer/puppeteer.dart';

class Buzzport with Diagnostics {
  /// Reference to browser instance.
  final Browser _browser;

  final Credential _credential;

  @override
  final String contextHint = 'Buzzport';

  final RegExp _oscarUrlRegex =
      RegExp(r'(https\:\/\/(?:.+)name=bmenu\.P_StuMainMnu)');

  final String duoAuthButtonSelector = 'button.positive.auth-button[type=submit]';

  /// Url to log into oscar - extracted when logged in.
  String oscarUrl;

  /// The page with buzzport open.
  Page page;

  Buzzport(this._browser, this._credential);

  /// Login into buzzport if needed.
  ///
  /// If the page is already open with buzzport logged in, nothing is done.
  /// Important Note: Duo authentication must have a default authentication method
  /// for this to work. (i.e. automatic push Duo auth notification to phone)
  /// Todo: what if session expires (should reload page, or re-login)
  Future<Page> loginIfNeeded() async {
    if (page != null) {
      return page;
    }
    info('opening new page for Buzzport');
    page = await _browser.newPage();
    info('login into Buzzport');
    await page.goto(
        'https://login.gatech.edu/cas/login?service=https%3A%2F%2Fbuzzport.gatech.edu%2Fmy%2F',
        wait: Until.networkIdle);

    info('authenticating using username & password');
    info('waiting for Duo challenge, please respond on mobile device');
    await page.type('#username', _credential.username);
    await page.type('#password', _credential.password);
    await page.clickAndWaitForNavigation('input[name=submit]', wait: Until.networkIdle);
    info('Duo auth acknowledged, navigating to buzzport');
    return page.waitForSelector('#panel-registration-and-student-services').then((_) {
      return _extractOscarUrl();
    }).then((url) {
      oscarUrl = url;
      info('successfully logged in');
      return page;
    }).catchError((e) async {
      error(e.toString());
      await screenshot(page, 'buzzport_login_error');
      throw e;
    });
  }

  Future<String> _extractOscarUrl() async {
    return page.content.then((content) {
      return _oscarUrlRegex.firstMatch(content).group(1);
    });
  }

  /// Convenient constructor for oscar.
  Oscar oscar() {
    return Oscar(_browser, oscarUrl);
  }
}
