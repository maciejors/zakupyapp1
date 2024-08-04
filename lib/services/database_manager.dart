import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:zakupyapp/core/models/product.dart';
import 'package:zakupyapp/core/models/deadline.dart';

/// A singleton responsible for interactions with the database
class DatabaseManager {
  static DatabaseManager _instance = DatabaseManager._();
  static DatabaseManager get instance => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  DocumentReference? _shoppingListDoc = null;
  CollectionReference? _productsCollection = null;

  StreamSubscription? _dataStream = null;

  // a private constructor
  DatabaseManager._();

  /// Creates a new Product object from raw data.
  /// Returns [null] if data format is invalid
  Product? _getProductFromDoc(QueryDocumentSnapshot docSnapshot) {
    try {
      var productRawData = docSnapshot.data() as Map;
      String id = docSnapshot.id;

      String productName = productRawData['name']!;
      String whoAdded = productRawData['whoAdded']!;
      DateTime dateAdded = (productRawData['dateAdded']! as Timestamp).toDate();

      String? whoLastEdited;
      DateTime? dateLastEdited;
      if (productRawData['dateLastEdited'] != null) {
        whoLastEdited = productRawData['whoLastEdited']!;
        dateLastEdited =
            (productRawData['dateLastEdited'] as Timestamp).toDate();
      }

      String? shopName = productRawData['shop'];
      Deadline? deadline;
      if (productRawData['deadline'] != null) {
        deadline =
            Deadline((productRawData['deadline']! as Timestamp).toDate());
      }
      String? buyer = productRawData['buyer'];

      double? quantity;
      String? quantityUnit;
      if (productRawData['quantity'] != null) {
        quantity = double.parse(productRawData['quantity']);
        quantityUnit = productRawData['quantityUnit']!;
      }

      return Product(
        id: id,
        name: productName,
        shop: shopName,
        dateAdded: dateAdded,
        whoAdded: whoAdded,
        dateLastEdited: dateLastEdited,
        whoLastEdited: whoLastEdited,
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

  /// Get map with all product data. The returned map does not contain the ID
  /// of the product
  Map<String, Object> _getMapFromProduct(Product product) {
    var productData = {
      'name': product.name,
      'dateAdded': Timestamp.fromDate(product.dateAdded),
      'whoAdded': product.whoAdded,
    };
    if (product.shop != null) {
      productData['shop'] = product.shop!;
    }
    if (product.deadline != null) {
      productData['deadline'] =
          Timestamp.fromDate(product.deadline!.deadlineDay);
    }
    if (product.buyer != null) {
      productData['buyer'] = product.buyer!;
    }
    if (product.quantity != null) {
      productData['quantity'] = product.quantity.toString();
      productData['quantityUnit'] = product.quantityUnit!;
    }
    if (product.dateLastEdited != null) {
      productData['dateLastEdited'] =
          Timestamp.fromDate(product.dateLastEdited!);
      productData['whoLastEdited'] = product.whoLastEdited!;
    }
    productData['modelVersion'] = '2';
    return productData;
  }

  /// Sets up the database reference pointing to the specified
  /// shopping list
  void setShoppingList(String shoppingListId) {
    // second condition is not likely to ever evaluate to true
    // since invalid ids are not accepted by the local storage manager
    if (shoppingListId.length == 0 ||
        shoppingListId.contains(RegExp(r'[/#.$\[\]]'))) return;

    _shoppingListDoc =
        _db.collection('shoppingListsPrivate').doc(shoppingListId);
    _productsCollection = _shoppingListDoc!.collection('products');
  }

  Future<List<String>> getDefaultShops() async {
    if (_shoppingListDoc == null) {
      return [];
    }

    var shoppingListSnapshot = await _shoppingListDoc!.get();
    if (!shoppingListSnapshot.exists) {
      // shopping list does not exist
      return [];
    }

    List<String> defaultShops =
        await shoppingListSnapshot.get('defaultShops').cast<String>();
    return defaultShops;
  }

  /// Stores a single product.
  /// Takes a product class object as an argument
  Future<void> storeProductFromClass(Product product) async {
    String productId = product.id;
    Map<String, Object> productData = _getMapFromProduct(product);
    await _productsCollection?.doc(productId).set(productData);
  }

  /// Sets a buyer attribute on a product.
  /// Set [buyer] to [null] to remove this attribue.
  Future<void> setProductBuyer(String productId, String? buyer) async {
    await _productsCollection?.doc(productId).update({'buyer': buyer});
  }

  Future<void> removeProduct(String productId) async {
    await _productsCollection?.doc(productId).delete();
  }

  /// Sets up a live listener on the specified shopping list
  void setupListener(void Function(List<Product> shoppingList) onUpdate) {
    _dataStream = _productsCollection
        ?.orderBy('dateAdded', descending: true)
        .snapshots()
        .listen((event) {
      var docs = event.docs;
      List<Product> products = docs
          .map(_getProductFromDoc)
          .where((p) => p != null) // skip products that have failed to parse
          .cast<Product>()
          .toList();
      onUpdate(products);
    });
  }

  Future<void> cancelListener() async {
    await _dataStream?.cancel();
  }
}
