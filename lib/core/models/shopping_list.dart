/// Represents a shopping list
class ShoppingList {
  final String id;
  final String name;

  /// a list of members emails
  final List<String> members;
  final List<String> defaultShops;

  ShoppingList({
    required this.id,
    required this.name,
    required this.members,
    required this.defaultShops,
  });

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != ShoppingList) return false;
    return id == (other as ShoppingList).id;
  }
}
