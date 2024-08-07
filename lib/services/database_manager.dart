import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:zakupyapp/core/models/product.dart';
import 'package:zakupyapp/core/models/deadline.dart';
import 'package:zakupyapp/core/models/shopping_list.dart';

/// A singleton responsible for interactions with the database
class DatabaseManager {
  static DatabaseManager _instance = DatabaseManager._();
  static DatabaseManager get instance => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference get _shoppingListPrivate =>
      _db.collection('shoppingListsPrivate');
  CollectionReference get _shoppingListPublic =>
      _db.collection('shoppingListsPublic');

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

  ShoppingList _getShoppingListFromDoc(
    QueryDocumentSnapshot publicDoc,
    QueryDocumentSnapshot privateDoc,
  ) {
    final publicDocData = publicDoc.data() as Map;
    final privateDocData = privateDoc.data() as Map;
    String id = publicDoc.id;
    String name = privateDocData['name']!;
    List<String> members = publicDocData['members']!.cast<String>();
    List<String> defaultShops = privateDocData['defaultShops'] != null
        ? privateDocData['defaultShops']!.cast<String>()
        : [];
    return ShoppingList(
      id: id,
      name: name,
      members: members,
      defaultShops: defaultShops,
    );
  }

  DocumentReference _getShoppingListPrivateDocRef(String shoppingListId) {
    return _shoppingListPrivate.doc(shoppingListId);
  }

  CollectionReference _getProductsCollectionRef(String shoppingListId) {
    return _getShoppingListPrivateDocRef(shoppingListId).collection('products');
  }

  Future<List<String>> getDefaultShops(String shoppingListId) async {
    final shoppingListDoc = _getShoppingListPrivateDocRef(shoppingListId);

    final shoppingListSnapshot = await shoppingListDoc.get();
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
  Future<void> storeProductFromClass(
      String shoppingListId, Product product) async {
    String productId = product.id;
    Map<String, Object> productData = _getMapFromProduct(product);
    final productsCollection = _getProductsCollectionRef(shoppingListId);
    await productsCollection.doc(productId).set(productData);
  }

  /// Sets a buyer attribute on a product.
  /// Set [buyer] to [null] to remove this attribue.
  Future<void> setProductBuyer(
      String shoppingListId, String productId, String? buyer) async {
    final productsCollection = _getProductsCollectionRef(shoppingListId);
    await productsCollection.doc(productId).update({'buyer': buyer});
  }

  Future<void> removeProduct(String shoppingListId, String productId) async {
    final productsCollection = _getProductsCollectionRef(shoppingListId);
    await productsCollection.doc(productId).delete();
  }

  /// Sets up a live listener on the specified shopping list
  StreamSubscription<QuerySnapshot<Object?>> setupListener(
    String shoppingListId,
    void Function(List<Product> shoppingList) onUpdate,
  ) {
    final productsCollection = _getProductsCollectionRef(shoppingListId);
    final dataStream = productsCollection
        .orderBy('dateAdded', descending: true)
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
    return dataStream;
  }

  Future<List<ShoppingList>> getShoppingListsForUser(String userEmail) async {
    // 1. fetch public shopping lists to find the ones that the user belongs to
    final shoppingListsPublicData = await _shoppingListPublic
        .where('members', arrayContains: userEmail)
        .orderBy(FieldPath.documentId)
        .get();
    final publicDocsSnapshots = shoppingListsPublicData.docs;
    // 2. get a list of shopping list ids
    List<String> shoppingListsIds = publicDocsSnapshots
        .map((shoppingListPublicDoc) => shoppingListPublicDoc.id)
        .toList();
    // 3. paginate the above list to fetch private data of shopping lists
    int totalShoppingLists = shoppingListsIds.length;
    List<QueryDocumentSnapshot> privateDocsSnapshots = [];
    final pageSize = 30;
    for (var startIdx = 0;
        startIdx < totalShoppingLists;
        startIdx += pageSize) {
      int endIdx = min(totalShoppingLists, startIdx + pageSize);
      List<String> shoppingListsIdsToFetch =
          shoppingListsIds.sublist(startIdx, endIdx);
      final newSnapshots = await _shoppingListPrivate
          .where(FieldPath.documentId, whereIn: shoppingListsIdsToFetch)
          .orderBy(FieldPath.documentId)
          .get();
      privateDocsSnapshots.addAll(newSnapshots.docs);
    }
    // 4. merge private and public docs data
    List<ShoppingList> shoppingLists = [];
    for (var i = 0; i < totalShoppingLists; i++) {
      final publicDoc = publicDocsSnapshots[i];
      final privateDoc = privateDocsSnapshots[i];
      print('getShoppingListsForUser: ${publicDoc.id} = ${privateDoc.id}');
      shoppingLists.add(_getShoppingListFromDoc(publicDoc, privateDoc));
    }
    return shoppingLists;
  }

  /// Adds a new member to the shopping list
  ///
  /// Note: to avoid fetching shopping list data for this operation, a check
  /// whether this user already belogs to the list should be done before
  /// calling this function, as it will add a new member regardless of whether
  /// he is in the list which can result in member duplication
  Future<void> addUserToShoppingList(
      String shoppingListId, String userEmail) async {
    await _shoppingListPublic.doc(shoppingListId).update({
      'members': FieldValue.arrayUnion([userEmail]),
    });
  }

  /// Removes a member from the shopping list
  Future<void> removeUserFromShoppingList(
      String shoppingListId, String userEmail) async {
    await _shoppingListPublic.doc(shoppingListId).update({
      'members': FieldValue.arrayRemove([userEmail]),
    });
  }

  Future<String> createShoppingList(String name, String creatorEmail) async {
    final publicDocData = {
      'members': [creatorEmail]
    };
    final privateDocData = {'name': name};
    final shoppingListRef = await _shoppingListPublic.add(publicDocData);
    final shoppingListId = shoppingListRef.id;
    await _shoppingListPrivate.doc(shoppingListId).set(privateDocData);
    return shoppingListId;
  }

  Future<void> renameShoppingList(String shoppingListId, String newName) async {
    await _shoppingListPrivate.doc(shoppingListId).update({'name': newName});
  }

  Future<void> updateShoppingListDefaultShops(
    String shoppingListId,
    List<String> shopsToRemove,
    List<String> shopsToAdd,
  ) async {
    final shoppingListPrivateDoc = _shoppingListPrivate.doc(shoppingListId);
    await shoppingListPrivateDoc.update({
      'defaultShops': FieldValue.arrayUnion(shopsToAdd),
    });
    await shoppingListPrivateDoc.update({
      'defaultShops': FieldValue.arrayRemove(shopsToRemove),
    });
  }
}
