import 'package:zakupyapp/core/models/deadline.dart';

import 'package:zakupyapp/storage/storage_manager.dart';

/// Represents a product from a shopping list
class Product {
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

  bool get isDeclaredByUser => buyer == SM.getUsername();

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
    if (buyer != null) {
      result['buyer'] = buyer!;
    }
    if (quantity != null) {
      result['quantity'] = quantity.toString();
      result['quantityUnit'] = quantityUnit!;
    }
    if (dateLastEdited != null) {
      result['dateLastEdited'] = dateLastEdited.toString();
      result['whoLastEdited'] = whoLastEdited!;
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
