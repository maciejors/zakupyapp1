import 'package:package_info_plus/package_info_plus.dart';

/// A wrapper for the package\_info\_plus library.
/// Invoke the [AppInfo.initialise()] method before using
class AppInfo {

  static PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  static Future<void> initialise() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  static String getVersion() {
    return _packageInfo.version;
  }
}