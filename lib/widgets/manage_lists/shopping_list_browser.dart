import 'dart:async';

import 'package:flutter/material.dart';

import 'package:zakupyapp/core/models/shopping_list.dart';
import 'package:zakupyapp/services/database_manager.dart';
import 'package:zakupyapp/services/auth_manager.dart';
import 'package:zakupyapp/widgets/manage_lists/shopping_list_tile.dart';
import 'package:zakupyapp/widgets/shared/loading.dart';

class ShoppingListBrowser extends StatefulWidget {
  const ShoppingListBrowser({super.key});

  @override
  State<ShoppingListBrowser> createState() => _ShoppingListBrowserState();
}

class _ShoppingListBrowserState extends State<ShoppingListBrowser> {
  final _db = DatabaseManager.instance;
  final _auth = AuthManager.instance;

  List<ShoppingList>? shoppingLists;
  StreamSubscription? shoppingListsDataSubscription;

  @override
  void initState() {
    super.initState();
    String userEmail = _auth.getUserEmail()!;
    shoppingListsDataSubscription = _db.subscribeToShoppingLists(
      userEmail,
      (shoppingLists) => setState(() => this.shoppingLists = shoppingLists),
    );
  }

  @override
  void dispose() {
    shoppingListsDataSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return shoppingLists == null
        ? const Loading()
        : shoppingLists!.length == 0
            ? const Center(
                child:
                    const Text('Nie jesteś członkiem żadnej listy zakupowej.'),
              )
            : ListView(
                children: shoppingLists!
                    .map(
                      (shoppingList) => ShoppingListTile(
                        shoppingList: shoppingList,
                      ),
                    )
                    .toList());
  }
}
