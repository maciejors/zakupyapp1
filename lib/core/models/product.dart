import 'package:zakupyapp/core/models/deadline.dart';
import 'package:zakupyapp/services/auth_manager.dart';

/// Represents a product from a shopping list
class Product {
  static final AuthManager _auth = AuthManager.instance;

  // Whether the product actually exists or is just a dummy with default values
  final bool isVirtual;

  final String id;
  final String name;

  final String whoAdded;
  final DateTime dateAdded;
  final String? whoLastEdited;
  final DateTime? dateLastEdited;

  final String? shop;
  final Deadline? deadline;
  final String? buyer;

  final double? quantity;
  final String? quantityUnit;
  
  String? get quantityLabel => formQuantityLabel(quantity, quantityUnit);

  Product({
    this.isVirtual = false,
    required this.id,
    required this.name,
    required this.dateAdded,
    required this.whoAdded,
    this.dateLastEdited,
    this.whoLastEdited,
    this.shop,
    this.deadline,
    this.buyer,
    this.quantity,
    this.quantityUnit,
  });

  bool get isEditable {
    final isDeclaredByOthers = buyer != null && !isDeclaredByUser;
    return !isDeclaredByOthers;
  }

  bool get isDeclaredByUser => buyer == _auth.getUserDisplayName();

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
  
  // has to be static because it will be used in Product Editor where
  // there is no access to the Product instance
  static String? formQuantityLabel(double? quantity, String? quantityUnit) {
    if (quantity == null) {
      return null;
    }
    final String displayedQuantity;
    final int quantityToInt = quantity.toInt();
    if (quantityToInt == quantity) {
      // e.g 28.0
      displayedQuantity = quantityToInt.toString();
    } else {
      displayedQuantity = quantity.toString();
    }
    return '$displayedQuantity $quantityUnit';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != Product) return false;
    return id == (other as Product).id;
  }
}
