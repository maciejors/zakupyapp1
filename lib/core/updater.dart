import 'package:flutter/foundation.dart';
import 'package:zakupyapp/storage/database_manager.dart';
import 'package:zakupyapp/storage/storage_manager.dart';

import 'package:zakupyapp/utils/app_info.dart';
import 'package:zakupyapp/core/models/apprelease.dart';

class Updater {
  DatabaseManager _db = DatabaseManager.instance;
  // check is one-time per instance
  bool _checkedForUpdate = false;

  /// Checks whether a new version of the app is avaiable
  Future<void> checkForUpdate(void Function(AppRelease release)? updateAvailableCallback) async {
    // don't perform any action if any of the following is true:
    // - this instance of Updater has already checked for update
    // - updates are turned off
    // - application was compiled in debug mode
    if (_checkedForUpdate || !SM.getAreUpdatesEnabled() || kDebugMode) {
      return;
    }
    _checkedForUpdate = true;
    // check if the newest release is newer than current
    String currReleaseId = AppInfo.getVersion();
    AppRelease currRelease = AppRelease(
      id: currReleaseId,
      size: 0,  // not relevant
      downloadUrl: '',  // not relevant
    );
    AppRelease latestRelease = await _db.getLatestRelease();
    bool isUpdateAvailable =  currRelease.compareTo(latestRelease) < 0;

    if (isUpdateAvailable && updateAvailableCallback != null) {
      updateAvailableCallback(latestRelease);
    }
  }
}