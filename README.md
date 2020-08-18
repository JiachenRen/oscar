# Oscar

A simple API wrapper for Georgia Tech Buzzport login and Oscar registration services.

### How does it work?

Nothing special... the dart script just controls a headless Chrome and follow the normal
login process. This is possible thanks to the puppeteer package.

### How to use?

Just look under test/oscar_registration_test.dart to get a glimpse of what this API can do. (You can easily extend the functionalities, with a bit of code. I'm too lazy...)

### Examples

#### Login to Buzzport and take a screenshot

*Screenshots will be saved under .screenshots*

```dart
await Buzzport(browser, _credential).loginIfNeeded().then((page) {
  return screenshot(page, 'buzzport_login');
});
```

#### Get current schedule

Look in test/buzzport_login_test.dart