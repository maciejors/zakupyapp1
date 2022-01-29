import 'package:firebase_database/firebase_database.dart';
import 'package:zakupyapk/widgets/shopping_list_item.dart';

class DatabaseManager {
  static DatabaseManager _instance =
      DatabaseManager._new(FirebaseDatabase.instance.reference());
  static DatabaseManager _testInstance =
      DatabaseManager._new(FirebaseDatabase.instance.reference().child('test'));

  static DatabaseManager get instance => _instance;
  static DatabaseManager get testInstance => _testInstance;

  DatabaseReference _db;

  DatabaseManager._new(this._db);

  void storeProductFromClass(ShoppingListItem product) {
    storeProductFromData(product.id, product.toMap());
  }

  void storeProductFromData(String productId, Map<String, dynamic> productData) {
    _db.child('list').child(productId).set(productData);
  }
}
