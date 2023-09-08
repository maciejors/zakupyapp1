import 'package:shared_preferences/shared_preferences.dart';

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
    return _storage.getString('username') ?? 'Użytkownik bez nazwy';
  }

  static void setUsername(String username) {
    if (username == '') {
      username = 'Użytkownik bez nazwy';
    }
    _storage.setString('username', username.trim());
  }

  static bool getAreUpdatesEnabled() {
    return _storage.getBool('areUpdatesEnabled') ?? true;
  }

  static void setAreUpdatesEnabled(bool areUpdatesEnabled) {
    _storage.setBool('areUpdatesEnabled', areUpdatesEnabled);
  }

  static bool getHideProductsOthersDeclaredFlag() {
    return _storage.getBool('hideProductsOthersDeclaredFlag') ?? false;
  }

  static void setHideProductsOthersDeclaredFlag(bool hideProductsOthersDeclaredFlag) {
    _storage.setBool(
        'hideProductsOthersDeclaredFlag', hideProductsOthersDeclaredFlag);
  }
}
