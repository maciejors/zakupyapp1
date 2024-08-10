import 'dart:async';

import 'package:zakupyapp/core/models/product.dart';
import 'package:zakupyapp/services/auth_manager.dart';
import 'package:zakupyapp/services/database_manager.dart';
import 'package:zakupyapp/services/storage_manager.dart';

/// represents a product list which can be filtered etc
class ShoppingListController {
  final DatabaseManager _db = DatabaseManager.instance;
  final AuthManager _auth = AuthManager.instance;

  List<Product> _allProducts = [];
  List<Product> get filteredProducts => _filterProducts(_allProducts);
  bool isDataReady = false;

  List<String> availableShops = [];

  /// filterable shops will omit default shops that are not used
  /// i.e. display only shops that are present in the shopping list
  List<String> filterableShops = [];
  List<String> availableQuantityUnits = [];
  final String id;
  String get _username => _auth.getUserDisplayName() ?? '';

  final bool hideProductsOthersDeclared = SM.getHideProductsOthersDeclared();

  StreamSubscription? _dataStream = null;

  // constructor
  ShoppingListController(this.id);

  // callbacks
  void Function(List<Product>)? onProductsUpdated;
  void Function()? onDefaultShopsReveived;

  // filters
  bool _showOnlyDeclaredByUser = false;

  bool get showOnlyDeclaredByUser => _showOnlyDeclaredByUser;
  void set showOnlyDeclaredByUser(bool value) {
    // set filter
    _showOnlyDeclaredByUser = value;
    if (onProductsUpdated != null) {
      onProductsUpdated!(filteredProducts);
    }
  }

  String _filteredShop = '';

  /// Name of the shop serving as a filter.<br>
  /// Wildcard values:
  /// * '' (empty string) - no filter,
  /// * '~' - show items with no shop specified.
  String get filteredShop => _filteredShop;
  void set filteredShop(String value) {
    // set filter
    _filteredShop = value;
    if (onProductsUpdated != null) {
      onProductsUpdated!(filteredProducts);
    }
  }

  bool get isInitialised {
    return id != '';
  }

  bool get isShopFilterApplied {
    return filteredShop != '';
  }

  Future<void> storeProduct(Product product) async {
    await _db.storeProductFromClass(id, product);
  }

  Future<void> removeProduct(Product product) async {
    await _db.removeProduct(id, product.id);
  }

  /// Returns [true] if the buyer was added, [false] if the buyer was removed
  /// or [null] if no action was taken (when someone else delcared to buy
  /// that product)
  Future<bool?> toggleProductBuyer(Product product) async {
    // not delared yet
    if (product.buyer == null) {
      await _db.setProductBuyer(id, product.id, _username);
      return true;
    }
    // declared by the user
    else if (product.buyer == _username) {
      await _db.setProductBuyer(id, product.id, null);
      return false;
    }
    // declared by someone else
    return null;
  }

  /// Applies currently set filters to a given product list
  List<Product> _filterProducts(List<Product> productsToFilter) {
    Iterable<Product> result = [...productsToFilter];
    // shop filter
    if (isShopFilterApplied) {
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

  /// Refreshes available shops and quantity units lists based on the product
  /// data.
  void _refreshLists(List<String> defaultShops) {
    Set<String> shopsInList = {};
    availableQuantityUnits = ['szt.', 'kg', 'dag', 'L'];
    for (var product in _allProducts) {
      // add any new shops to the list of available shops
      if (product.shop != null) {
        shopsInList.add(product.shop!);
      }
      // add any new quantity units to the list of available qus
      if (product.quantityUnit != null &&
          !availableQuantityUnits.contains(product.quantityUnit)) {
        availableQuantityUnits.add(product.quantityUnit!);
      }
    }
    // filterable shops only requires shops present in the shopping list
    filterableShops = shopsInList.toList();
    // add all default shops to availableShops
    shopsInList.addAll(defaultShops);
    availableShops = shopsInList.toList();
  }

  /// Starts listening for products data. Make sure to set [onProductsUpdated]
  /// and [onDefaultShopsReceived] callbacks before calling this method.
  void subscribe() {
    // set default shops
    _db.getDefaultShops(id).then((value) {
      _refreshLists(value);
      // callback
      if (onDefaultShopsReveived != null) onDefaultShopsReveived!();
    });
    // setup product listener
    _dataStream = _db.subscribeToProducts(id, (newProducts) {
      newProducts.sort((p1, p2) => p2.dateAdded.compareTo(p1.dateAdded));

      isDataReady = true;

      _allProducts = newProducts;
      // received products may contain new shops
      _refreshLists(availableShops);
      // callback
      if (onProductsUpdated != null) onProductsUpdated!(filteredProducts);
    });
  }

  Future<void> unsubscribe() async {
    await _dataStream?.cancel();
  }
}
