/// Represents an app release
class AppRelease implements Comparable<AppRelease> {
  final String id;
  final int size;
  final String downloadUrl;

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
    List<int> verParts = id.split('.')
        .map(int.parse)
        .toList();
    List<int> otherVerParts = other.id.split('.')
        .map(int.parse)
        .toList();

    for (int i = 0; i < verParts.length; i++) {
      // checking all the version id numbers in order of importance
      if (verParts[i] != otherVerParts[i]) {
        return verParts[i].compareTo(otherVerParts[i]);
      }
    }
    return 0;
  }
}