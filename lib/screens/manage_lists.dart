import 'package:flutter/material.dart';

import 'package:zakupyapp/widgets/drawer/main_drawer.dart';
import 'package:zakupyapp/widgets/manage_lists/create_shopping_list_action.dart';
import 'package:zakupyapp/widgets/manage_lists/shopping_list_browser.dart';

class ManageListsScreen extends StatelessWidget {
  const ManageListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // this screen is accessible only to authenticated users
      drawer: const MainDrawer(isUserSignedIn: true),
      appBar: AppBar(
        title: const Text('Zarządzanie listami'),
        actions: <Widget>[
          const CreateShoppingListAction(),
        ],
      ),
      body: const ShoppingListBrowser(),
    );
  }
}
