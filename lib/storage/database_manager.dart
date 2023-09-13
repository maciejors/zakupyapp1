import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:zakupyapp/core/models/apprelease.dart';
import 'package:zakupyapp/core/models/product.dart';
import 'package:zakupyapp/core/models/deadline.dart';

/// A singleton responsible for interactions with the database
class DatabaseManager {
  static DatabaseManager _instance = DatabaseManager._();
  static DatabaseManager get instance => _instance;

  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  DatabaseReference? _shoppingListRef = null;
  DatabaseReference? _defaultShopsRef = null;
  final Reference _storage = FirebaseStorage.instance.ref();

  StreamSubscription? _dataStream = null;

  // a private constructor
  DatabaseManager._();

  Reference _getReleaseReference(String releaseId) {
    return _storage.child('releases').child('zakupyapp-$releaseId.apk');
  }

  /// Creates a new Product object from raw data.
  /// Returns [null] if data format is invalid
  Product? _getProductFromMap(MapEntry<Object?, Object?> rawData) {
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
      String? buyer = productRawData['buyer'];
      // default values for older products
      double quantity = productRawData['quantity'] ?? 1;
      String quantityUnit = productRawData['quantityUnit'] ?? 'szt.';

      return Product(
        id: id,
        name: productName,
        shop: shopName,
        dateAdded: dateAdded,
        whoAdded: whoAdded,
        deadline: deadline,
        buyer: buyer,
        quantity: quantity,
        quantityUnit: quantityUnit,
      );
    } catch (e) {
      print('Failed to parse a product due to a following error:\n$e');
      return null;
    }
  }

  /// Sets up the database reference pointing to the specified
  /// shopping list
  void setShoppingList(String shoppingListId) {
    // second condition is not likely to ever evaluate to true
    // since invalid ids are not accepted by the local storage manager
    if (shoppingListId.length == 0 ||
        shoppingListId.contains(RegExp(r'[/#.$\[\]]'))) return;

    _shoppingListRef = _db.child('shopping-lists/$shoppingListId/products');
    _defaultShopsRef =
        _db.child('shopping-lists/$shoppingListId/default-shops');
  }

  Future<List<String>> getDefaultShops() async {
    if (_shoppingListRef == null) {
      return [];
    }
    var snapshot = await _defaultShopsRef!.get();
    if (!snapshot.exists) {
      // no default shops
      return [];
    }
    List<Object?> snapshotValue = snapshot.value as List<Object?>;
    return snapshotValue.cast<String>();
  }

  /// Stores a single product.
  /// Takes a product class object as an argument
  Future<void> storeProductFromClass(Product product) async {
    await storeProductFromData(product.id, product.toMap());
  }

  /// Stores a single product.
  /// Takes a product data map as an argument
  Future<void> storeProductFromData(
      String productId, Map<String, String> productData) async {
    productData['modelVersion'] = '2';
    await _shoppingListRef?.child(productId).set(productData);
  }

  /// Sets a buyer attribute on a product.
  /// Set [buyer] to [null] to remove this attribue.
  Future<void> setProductBuyer(String productId, String? buyer) async {
    if (buyer == null) {
      await _shoppingListRef?.child(productId).child('buyer').remove();
    } else {
      await _shoppingListRef?.child(productId).child('buyer').set(buyer);
    }
  }

  Future<void> removeProduct(String productId) async {
    await _shoppingListRef?.child(productId).remove();
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
            .map(_getProductFromMap)
            .where((p) => p != null) // skip products that have failed to parse
            .cast<Product>()
            .toList();
      }
      onUpdate(products);
    });
  }

  Future<void> cancelListener() async {
    await _dataStream?.cancel();
  }

  /// Retrieves the latest release data from the database
  Future<AppRelease> getLatestRelease() async {
    ListResult apkNames = await _storage.child('releases').listAll();
    String latestReleaseId =
        AppRelease.getMaxVersion(apkNames.items.map((ref) => ref.name));
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
