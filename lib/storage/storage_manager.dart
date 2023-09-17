import 'package:shared_preferences/shared_preferences.dart';
import 'package:zakupyapp/constants.dart';

class SM {
  static late SharedPreferences _storage;

  static Future<void> setupStorage() async {
    _storage = await SharedPreferences.getInstance();
  }

  static String getShoppingListId() {
    return _storage.getString('shoppingListId') ?? '';
  }

  static void setShoppingListId(String shoppingListId) {
    // remove characters with a special meaning to the firebase
    shoppingListId = shoppingListId.replaceAll(RegExp(r'[/#.$\[\]]'), '');

    _storage.setString('shoppingListId', shoppingListId.trim());
  }

  static String getUsername() {
    return _storage.getString('username') ?? Constants.DEFAULT_USERNAME;
  }

  static void setUsername(String username) {
    if (username == '') {
      username = Constants.DEFAULT_USERNAME;
    }
    _storage.setString('username', username.trim());
  }

  static bool getUseFamilyStore() {
    return _storage.getBool('useFamilyStore') ?? false;
  }

  static void setUseFamilyStore(bool useFamilyStore) {
    _storage.setBool('useFamilyStore', useFamilyStore);
  }

  static bool getHideProductsOthersDeclared() {
    return _storage.getBool('hideProductsOthersDeclared') ?? false;
  }

  static void setHideProductsOthersDeclared(bool hideProductsOthersDeclared) {
    _storage.setBool(
        'hideProductsOthersDeclared', hideProductsOthersDeclared);
  }
}
