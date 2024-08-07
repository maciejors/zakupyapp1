import 'package:flutter/material.dart';

import 'package:zakupyapp/core/models/shopping_list.dart';
import 'package:zakupyapp/services/database_manager.dart';
import 'package:zakupyapp/services/auth_manager.dart';
import 'package:zakupyapp/widgets/manage_lists/shopping_list_tile.dart';

class ShoppingListBrowser extends StatefulWidget {
  const ShoppingListBrowser({super.key});

  @override
  State<ShoppingListBrowser> createState() => _ShoppingListBrowserState();
}

class _ShoppingListBrowserState extends State<ShoppingListBrowser> {
  final _db = DatabaseManager.instance;
  final _auth = AuthManager.instance;

  @override
  Widget build(BuildContext context) {
    String userEmail = _auth.getUserEmail()!;

    return FutureBuilder(
      future: _db.getShoppingListsForUser(userEmail),
      builder: (BuildContext context,
          AsyncSnapshot<List<ShoppingList>> shoppingListsSnapshot) {
        if (shoppingListsSnapshot.hasData) {
          return ListView(
            children: shoppingListsSnapshot.data!
                .map(
                  (shoppingList) => ShoppingListTile(
                    shoppingList: shoppingList,
                  ),
                )
                .toList(),
          );
        } else if (shoppingListsSnapshot.hasError) {
          return AlertDialog(
            title: const Text('Wystąpił błąd'),
            content: const Text('Kod błędu: 2'),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
