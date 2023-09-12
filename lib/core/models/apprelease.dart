/// Represents an app release
class AppRelease implements Comparable<AppRelease> {
  final String id;
  final int size;
  String downloadUrl;

  AppRelease({required this.id, required this.size, required this.downloadUrl});

  /// Returns file size in MB rounded to cents
  double getRoundedSizeMB() {
    double sizeInMB = size / 1024 / 1024;
    double roundedSize = (sizeInMB * 100).roundToDouble() / 100;
    return roundedSize;
  }

  /// Compares which app release is newer
  @override
  int compareTo(AppRelease other) {
    // example: ver = '1.10.2' -> verParts = [1, 10, 2]
    List<int> verParts = id.split('.').map(int.parse).toList();
    List<int> otherVerParts = other.id.split('.').map(int.parse).toList();

    for (int i = 0; i < verParts.length; i++) {
      // checking all the version id numbers in order of importance
      if (verParts[i] != otherVerParts[i]) {
        return verParts[i].compareTo(otherVerParts[i]);
      }
    }
    return 0;
  }

  /// Finds the latest release from the listed file names
  /// (assuming that all the files have a version id in their name)
  static String getMaxVersion(Iterable<String> filenames) {
    String newestVersion = filenames
        .map((filename) {
      // extract version ids from file names
      RegExp regex = RegExp(r'zakupyapp-(\d+\.\d+\.\d+).apk');
      // extracting version id
      var match = regex.firstMatch(filename);
      // if a file name has an invalid format, it will be skipped
      if (match == null) {
        return null;
      }
      String? version = match.group(1)!;
      return version;
    })
        .where((element) => element != null)
        .cast<String>()
        .reduce((ver1, ver2) {
      // find the newest version
      // wrap with an AppRelease object since it implements Comparable
      // that compares versions
      var release1 = AppRelease(id: ver1, size: 0, downloadUrl: '');
      var release2 = AppRelease(id: ver2, size: 0, downloadUrl: '');
      // they can't be equal here anyway
      if (release1.compareTo(release2) > 0) {
        return release1.id;
      } else {
        return release2.id;
      }
    });

    return newestVersion;
  }

}
