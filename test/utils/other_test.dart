import 'package:flutter_test/flutter_test.dart';
import 'package:zakupyapp/utils/other.dart';

void main() {
  test('getMaxVersion() correctly returns the latest version ID', () {
    var filenames = [
      'zakupyapp-1.99.0.apk',
      'zakupyapp-1.3.199.apk',
      'zakupyapp-2.100.0.apk',
      'zakupyapp-2.2.99.apk'
    ];
    String latest = '2.100.0';
    expect(getMaxVersion(filenames), equals(latest));
  });
}
