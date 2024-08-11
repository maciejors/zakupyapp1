import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:zakupyapp/constants.dart';
import 'package:zakupyapp/utils/app_info.dart';

class Updater {
  // check is one-time per instance
  bool _checkedForUpdate = false;

  /// Retrieves the latest release version ID from Family Store
  Future<String> getLatestReleaseId() async {
    final response = await http.get(Uri.parse(Constants.familyStoreEndpoint));
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    return responseData['version']! as String;
  }

  /// Checks whether a new version of the app is avaiable
  Future<void> checkForUpdate(
      void Function(String newVersionId)? updateAvailableCallback) async {
    // don't perform any action if any of the following is true:
    // - this instance of Updater has already checked for update
    // - application was compiled in debug mode
    if (_checkedForUpdate || kDebugMode) {
      return;
    }
    _checkedForUpdate = true;
    // check if the newest release is newer than current
    String currReleaseId = AppInfo.getVersion();
    String latestReleaseId = await getLatestReleaseId();
    bool isUpdateAvailable = currReleaseId != latestReleaseId;

    if (isUpdateAvailable && updateAvailableCallback != null) {
      updateAvailableCallback(latestReleaseId);
    }
  }
}
