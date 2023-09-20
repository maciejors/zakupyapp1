import 'package:flutter_test/flutter_test.dart';
import 'package:zakupyapp/core/models/apprelease.dart';

void main() {
  group('getMaxVersion() correctly returns the latest version ID', () {
    test('Case 1', () {
      var filenames = [
        'zakupyapp-1.99.0.apk',
        'zakupyapp-1.3.199.apk',
        'zakupyapp-2.100.0.apk',
        'zakupyapp-2.2.99.apk',
      ];
      String latest = '2.100.0';
      expect(AppRelease.getMaxVersion(filenames), equals(latest));
    });
    test('Case 2', () {
      var filenames = [
        'zakupyapp-1.5.2.apk',
        'zakupyapp-1.5.0.apk',
      ];
      String latest = '1.5.2';
      expect(AppRelease.getMaxVersion(filenames), equals(latest));
    });
  });

  group('compareTo() correcly compares app versions', () {
    test('One newer than the other', () {
      var olderRelease = AppRelease(id: '9.9.9', size: 99999, downloadUrl: '');
      var newerRelease = AppRelease(id: '10.0.0', size: 10, downloadUrl: '');
      expect(olderRelease.compareTo(newerRelease), equals(-1));
    });
    test('Equality', () {
      var release1 = AppRelease(id: '1.1.1', size: 99999, downloadUrl: '');
      var release2 = AppRelease(id: '1.1.1', size: 10, downloadUrl: '');
      expect(release1.compareTo(release2), equals(0));
    });
  });

  test('getRoundedSizeMB gives accurate result', () {
    var release = AppRelease(id: '', size: 12345678, downloadUrl: '');
    double roundedSizeMB = 11.77;
    expect(release.getRoundedSizeMB(), equals(roundedSizeMB));
  });
}
