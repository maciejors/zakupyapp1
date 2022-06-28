import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:zakupyapk/core/product.dart';
import 'package:zakupyapk/utils/app_info.dart';

/// A singleton responsible for interactions with the database
class DatabaseManager {
  static DatabaseManager _instance =
      DatabaseManager._();
  static DatabaseManager get instance => _instance;

  final _db = FirebaseDatabase.instance.ref();
  final _storage = FirebaseStorage.instance;

  // a private constructor
  DatabaseManager._();

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
    String currVersion = AppInfo.getVersion();

    DataSnapshot snapshot = await _db.child('version').get();
    String newestVersion = snapshot.value! as String;

    return newestVersion != currVersion;
  }
}
