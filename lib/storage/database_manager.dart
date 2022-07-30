import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:zakupyapk/core/apprelease.dart';
import 'package:zakupyapk/core/product.dart';
import 'package:zakupyapk/utils/app_info.dart';
import 'package:zakupyapk/utils/other.dart';

import '../core/deadline.dart';
import '../core/product.dart';

/// A singleton responsible for interactions with the database
class DatabaseManager {
  static DatabaseManager _instance = DatabaseManager._();
  static DatabaseManager get instance => _instance;

  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  DatabaseReference? _shoppingListRef = null;
  final Reference _storage = FirebaseStorage.instance.ref();

  StreamSubscription? _dataStream = null;

  // a private constructor
  DatabaseManager._();

  Reference _getReleaseReference(String releaseId) {
    return _storage.child('releases').child('zakupyapp-$releaseId.apk');
  }

  /// Creates a new Product object from raw data.
  /// Returns [null] if data format is invalid
  Product? _getProduct(MapEntry<Object?, Object?> rawData) {
    try {
      var productRawData = rawData.value as Map;
      String id = rawData.key as String;

      String productName = productRawData['name']!;
      String whoAdded = productRawData['whoAdded']!;
      DateTime dateAdded = DateTime.parse(productRawData['dateAdded']!);

      String? shopName = productRawData['shop'];
      Deadline? deadline;
      if (productRawData['deadline'] != null) {
        deadline = Deadline.parse(productRawData['deadline']!);
      }

      return Product(
          id: id,
          name: productName,
          shop: shopName,
          dateAdded: dateAdded,
          whoAdded: whoAdded,
          deadline: deadline);
    } catch (_) {
      return null;
    }
  }

  /// Sets up the database reference pointing to the specified
  /// shopping list
  void setShoppingList(String shoppingListId) {
    _shoppingListRef = FirebaseDatabase.instance
        .ref('list2/$shoppingListId'); //TODO: list2 -> list
  }

  /// Stores a single product.
  /// Takes a product class object as an argument
  void storeProductFromClass(Product product) {
    storeProductFromData(product.id, product.toMap());
  }

  /// Stores a single product.
  /// Takes a product data map as an argument
  void storeProductFromData(String productId, Map<String, String> productData) {
    _shoppingListRef?.child(productId).set(productData);
  }

  void removeProduct(String productId) {
    _shoppingListRef?.child(productId).remove();
  }

  /// Sets up a live listener on the specified shopping list
  void setupListener(void Function(List<Product> shoppingList) onUpdate) {
    _dataStream = _shoppingListRef?.onValue.listen((event) {
      List<Product> products;
      if (event.snapshot.value == null) {
        products = [];
      } else {
        var data = event.snapshot.value as Map<Object?, Object?>;
        products = data.entries
            .map(_getProduct)
            .where((p) => p != null)  // skip products that have failed to parse
            .cast<Product>()
            .toList();
      }
      onUpdate(products);
    });
  }

  void cancelListener() {
    _dataStream?.cancel();
  }

  /// Checks whether a new version of the app is avaiable in the database
  Future<bool> isUpdateAvailable() async {
    AppRelease currReleaseId = AppRelease(
      id: AppInfo.getVersion(), // this is the only relevant argument here
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
