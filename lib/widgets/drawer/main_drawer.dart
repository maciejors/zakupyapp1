import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:zakupyapp/constants.dart';
import 'package:zakupyapp/widgets/drawer/change_shopping_list_dialog.dart';
import 'package:zakupyapp/widgets/drawer/help_dialog.dart';
import 'package:zakupyapp/services/storage_manager.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  void switchScreen(BuildContext context, String routeName) {
    if (ModalRoute.of(context)!.settings.name == routeName) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacementNamed(context, routeName);
    }
  }

  Future<void> changeShoppingList(BuildContext context) async {
    String? newShoppingListId = await showDialog<String>(
        context: context, builder: (ctx) => const ChangeShoppingListDialog());
    if (newShoppingListId == null) {
      return;
    }
    SM.setShoppingListId(newShoppingListId);
    // reload page to fetch a new shopping list
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> showHelpDialog(BuildContext context) async {
    await showDialog(context: context, builder: (ctx) => const HelpDialog());
  }

  Future<void> viewInFamilyStore() async {
    Uri uri = Uri.parse(Constants.FAMILY_STORE_APP_URL);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            // logo at the top
            child: Image.asset('assets/images/logo.png'),
            decoration: const BoxDecoration(color: Colors.orange),
          ),
          ListTile(
            // shopping list
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Lista zakupów'),
            onTap: () => switchScreen(context, '/'),
          ),
          ListTile(
            leading: const Icon(Icons.change_circle),
            title: const Text('Zmień listę'),
            onTap: () async => await changeShoppingList(context),
          ),
          ListTile(
            // shopping list
            leading: const Icon(Icons.edit),
            title: const Text('Zarządzaj listami'),
            onTap: () => switchScreen(context, '/manage-lists'),
          ),
          ListTile(
            // settings
            leading: const Icon(Icons.settings),
            title: const Text('Ustawienia'),
            onTap: () => switchScreen(context, '/settings'),
          ),
          ListTile(
            // settings
            leading: const Icon(Icons.help),
            title: const Text('Pomoc'),
            onTap: () async => await showHelpDialog(context),
          ),
          ListTile(
            // settings
            leading: const Icon(Icons.launch),
            title: const Text('Wyświetl aplikację w Family Store'),
            onTap: viewInFamilyStore,
          ),
        ],
      ),
    );
  }
}
