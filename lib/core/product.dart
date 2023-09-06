import 'package:zakupyapp/core/deadline.dart';

/// Represents a product from a
class Product {
  static List<String> allAvailableShops = [
    'Biedronka',
    'Lidl',
    'Selgros',
    'Emilka'
  ];

  final String id;
  final String name;
  final String whoAdded;
  final DateTime dateAdded;

  final String? shop;
  final Deadline? deadline;

  Product(
      {required this.id,
      required this.name,
      required this.dateAdded,
      required this.whoAdded,
      this.shop,
      this.deadline}) {
    // adding custom shops
    if (shop != null &&
        !allAvailableShops.contains(shop) &&
        // true for settings screen
        shop != 'Przykładowy') {
      allAvailableShops.add(shop!);
    }
  }

  /// Map does not contain ID of the product
  Map<String, String> toMap() {
    var result = {
      'name': name,
      'dateAdded': dateAdded.toString(),
      'whoAdded': whoAdded,
    };
    if (shop != null) {
      result['shop'] = shop!;
    }
    if (deadline != null) {
      result['deadline'] = deadline.toString();
    }
    return result;
  }

  static String generateProductId() {
    DateTime now = DateTime.now();
    return '${now.year}'
        '-${now.month.toString().padLeft(2, '0')}'
        '-${now.day.toString().padLeft(2, '0')}'
        '-${now.hour.toString().padLeft(2, '0')}'
        '-${now.minute.toString().padLeft(2, '0')}'
        '-${now.second.toString().padLeft(2, '0')}'
        '-${now.millisecond.toString().padLeft(3, '0')}';
  }
}
