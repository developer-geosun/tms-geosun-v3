import 'package:flutter_test/flutter_test.dart';

import 'package:tms_geosun/auth/domain/password_rules.dart';

void main() {
  test('meetsPasswordPolicy збігається з backend-правилом', () {
    expect(meetsPasswordPolicy('Secret12'), isTrue);
    expect(meetsPasswordPolicy('short'), isFalse);
    expect(meetsPasswordPolicy('abcdefgh'), isFalse);
    expect(meetsPasswordPolicy('12345678'), isFalse);
  });
}
