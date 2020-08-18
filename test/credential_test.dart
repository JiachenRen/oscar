import 'package:flutter_test/flutter_test.dart';
import 'package:oscar/models/data_models/credential.dart';

void main() async {
  test('Test Credential', () async {
    await Credential(username: 'anonymous', password: '123456789').save();
    var credential = await Credential.load();
    assert(credential.username == 'anonymous');
    assert(credential.password == '123456789');
  });
}