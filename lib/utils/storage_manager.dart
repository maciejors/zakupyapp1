import 'package:shared_preferences/shared_preferences.dart';

class SM {

  static late SharedPreferences _storage;

  static Future<void> setupStorage() async {
    _storage = await SharedPreferences.getInstance();
  }

  static double getMainFontSize() {
    return _storage.getDouble('mainFontSize') ?? 14.0;
  }

  static String getUserName() {
    return _storage.getString('username') ?? 'Użytkownik bez nazwy';
  }

  static void setMainFontSize(double mainFontSize) {
    _storage.setDouble('mainFontSize', mainFontSize);
  }

  static void setUserName(String username) {
    _storage.setString('username', username);
  }
}