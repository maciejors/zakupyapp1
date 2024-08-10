import 'package:flutter/material.dart';

import 'package:zakupyapp/services/auth_manager.dart';
import 'package:zakupyapp/services/database_manager.dart';
import 'package:zakupyapp/services/storage_manager.dart';
import 'package:zakupyapp/core/models/shopping_list.dart';

class ChangeShoppingListDialog extends StatefulWidget {
  const ChangeShoppingListDialog({super.key});

  @override
  State<ChangeShoppingListDialog> createState() =>
      _ChangeShoppingListDialogState();
}

class _ChangeShoppingListDialogState extends State<ChangeShoppingListDialog> {
  final _db = DatabaseManager.instance;
  final _auth = AuthManager.instance;

  @override
  Widget build(BuildContext context) {
    String userEmail = _auth.getUserEmail()!;
    String currentShoppingListId = SM.getShoppingListId();

    return FutureBuilder(
      future: _db.getShoppingListsForUser(userEmail),
      builder: (BuildContext context,
          AsyncSnapshot<List<ShoppingList>> shoppingListsSnapshot) {
        if (shoppingListsSnapshot.hasData) {
          return SimpleDialog(
            title: const Text('Wybierz listę zakupów'),
            children: shoppingListsSnapshot.data!
                .map((shoppingList) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, shoppingList.id),
                      child: shoppingList.id == currentShoppingListId
                          ? Text(
                              shoppingList.name,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : Text(shoppingList.name),
                    ))
                .toList(),
          );
        } else if (shoppingListsSnapshot.hasError) {
          return AlertDialog(
            title: const Text('Wystąpił błąd'),
            content: const Text('Kod błędu: 1'),
          );
        } else {
          return Center(child: const CircularProgressIndicator());
        }
      },
    );
  }
}
