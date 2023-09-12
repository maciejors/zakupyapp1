import 'package:zakupyapp/core/models/product.dart';
import 'package:zakupyapp/storage/database_manager.dart';

import '../storage/storage_manager.dart';

/// represents a product list which can be filtered etc
class ShoppingList {
  List<Product> _products = [];
  List<String> availableShops = [];
  final String _id = SM.getShoppingListId();
  final String _username = SM.getUsername();

  final bool hideProductsOthersDeclared =
      SM.getHideProductsOthersDeclaredFlag();
  bool showOnlyDeclaredByUser = false;

  /// Name of the shop serving as a filter.<br>
  /// Wildcard values:
  /// * '' (empty string) - no filter,
  /// * '~' - show items with no shop specified.
  String filteredShop = '';

  DatabaseManager _db = DatabaseManager.instance;

  bool get isInitialised {
    return _id != '';
  }

  bool get isEmpty {
    return _products.isEmpty;
  }

  bool get shopFilterApplied {
    return filteredShop != '';
  }

  Future<void> storeProduct(Product product) async {
    await _db.storeProductFromClass(product);
  }

  Future<void> removeProduct(Product product) async {
    await _db.removeProduct(product.id);
  }

  /// Returns [true] if the buyer was added, [false] if the buyer was removed
  /// or [null] if no action was taken (when someone else delcared to buy
  /// that product)
  Future<bool?> toggleProductBuyer(Product product) async {
    // not delared yet
    if (product.buyer == null) {
      await _db.setProductBuyer(product.id, _username);
      return true;
    }
    // declared by the user
    else if (product.buyer == _username) {
      await _db.setProductBuyer(product.id, null);
      return false;
    }
    // declared by someone else
    return null;
  }

  List<Product> getProductsToDisplay() {
    Iterable<Product> result = [..._products];
    // shop filter
    if (shopFilterApplied) {
      result = result.where((item) {
        if (filteredShop == '~') {
          return item.shop == null;
        }
        return item.shop == filteredShop;
      });
    }
    // buyer filter
    if (showOnlyDeclaredByUser) {
      result = result.where((p) => p.buyer == _username);
    }
    // check if user wants to see products that others declared to buy
    if (hideProductsOthersDeclared) {
      result = result.where((p) => p.buyer == null || p.buyer == _username);
    }
    return result.toList();
  }

  void _refreshAvailableShops(List<String> defaultShops) {
    availableShops = [...defaultShops];
    // add any new shops to the list of available shops
    for (var product in _products) {
      if (product.shop != null && !availableShops.contains(product.shop)) {
        availableShops.add(product.shop!);
      }
    }
  }

  void startListening(
      {required void Function() onProductsUpdatedCallback,
      required void Function() onDefaultShopsReveivedCallback}) {
    _db.setShoppingList(_id);
    // set default shops
    _db.getDefaultShops().then((value) {
      _refreshAvailableShops(value);
      onDefaultShopsReveivedCallback();
    });
    // setup product listener
    _db.setupListener((newProductsList) {
      newProductsList.sort((p1, p2) => p2.dateAdded.compareTo(p1.dateAdded));
      this._products = newProductsList;
      // received products may contain new shops
      _refreshAvailableShops(availableShops);
      // callback
      onProductsUpdatedCallback();
    });
  }

  Future<void> stopListening() async {
    await _db.cancelListener();
  }
}
