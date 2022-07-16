import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:zakupyapk/core/apprelease.dart';
import 'package:zakupyapk/core/product.dart';
import 'package:zakupyapk/utils/app_info.dart';
import 'package:zakupyapk/utils/other.dart';

/// A singleton responsible for interactions with the database
class DatabaseManager {
  static DatabaseManager _instance = DatabaseManager._();
  static DatabaseManager get instance => _instance;

  final _db = FirebaseDatabase.instance.ref();
  final _storage = FirebaseStorage.instance.ref();

  // a private constructor
  DatabaseManager._();

  Reference _getReleaseReference(String releaseId) {
    return _storage.child('releases').child('zakupyapp-$releaseId.apk');
  }

  /// Stores a single product.
  /// Takes a product class object as an argument
  void storeProductFromClass(Product product) {
    storeProductFromData(product.id, product.toMap());
  }

  /// Stores a single product.
  /// Takes a product data map as an argument
  void storeProductFromData(String productId, Map<String, String> productData) {
    _db.child('list').child(productId).set(productData);
  }

  /// Checks whether a new version of the app is avaiable in the database
  Future<bool> isUpdateAvailable() async {
    AppRelease currReleaseId = AppRelease(
      id: AppInfo.getVersion(),  // this is the only relevant argument here
      size: 0,
      downloadUrl: '',
    );
    AppRelease latestRelease = await getLatestRelease();

    return currReleaseId.compareTo(latestRelease) < 0;
  }

  /// Retrieves the latest release data from the database
  Future<AppRelease> getLatestRelease() async {
    ListResult apkNames = await _storage.child('releases').listAll();
    String latestReleaseId =
        getMaxVersion(apkNames.items.map((ref) => ref.name));
    var latestReleaseRef = _getReleaseReference(latestReleaseId);

    var meta = await latestReleaseRef.getMetadata();
    int size = meta.size!;
    String downloadUrl = await latestReleaseRef.getDownloadURL();

    return AppRelease(
      id: latestReleaseId,
      size: size,
      downloadUrl: downloadUrl,
    );
  }
}
