import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zakupyapp/constants.dart';

import 'package:zakupyapp/widgets/drawer/help_dialog.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  void switchScreen(BuildContext context, String routeName) {
    if (ModalRoute.of(context)!.settings.name == routeName) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacementNamed(context, routeName);
    }
  }

  Future<void> showHelpDialog(BuildContext context) async {
    await showDialog(context: context, builder: (ctx) => HelpDialog());
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
          decoration: BoxDecoration(color: Colors.orange),
        ),
        ListTile(
          // shopping list
          leading: Icon(Icons.shopping_cart),
          title: Text('Lista zakupów'),
          onTap: () {
            switchScreen(context, '/');
          },
        ),
        ListTile(
          // settings
          leading: Icon(Icons.settings),
          title: Text('Ustawienia'),
          onTap: () {
            switchScreen(context, '/settings');
          },
        ),
        ListTile(
          // settings
          leading: Icon(Icons.help),
          title: Text('Pomoc'),
          onTap: () async => await showHelpDialog(context),
        ),
        ListTile(
          // settings
          leading: Icon(Icons.launch),
          title: Text('Wyświetl aplikację w Family Store'),
          onTap: viewInFamilyStore,
        ),
      ],
    ));
  }
}
