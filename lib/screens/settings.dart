import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zakupyapp/core/updater.dart';

import 'package:zakupyapp/storage/storage_manager.dart';
import 'package:zakupyapp/utils/app_info.dart';
import 'package:zakupyapp/widgets/drawer/main_drawer.dart';
import 'package:zakupyapp/widgets/settings/settings_group_title.dart';

import '../widgets/shared/update_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _shoppingListIdInput = '';
  String _usernameInput = '';

  Future<void> showEditShoppingListIdDialog(BuildContext ctx) async {
    _shoppingListIdInput = SM.getShoppingListId();
    await showDialog(
        context: ctx,
        builder: (ctx) => AlertDialog(
              title: Text('ID Listy zakupów'),
              content: TextFormField(
                initialValue: SM.getShoppingListId(),
                decoration: InputDecoration(label: Text('Wpisz ID...')),
                onChanged: (newValue) {
                  setState(() {
                    _shoppingListIdInput = newValue;
                  });
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Anuluj'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                TextButton(
                  child: Text('Zapisz'),
                  onPressed: () {
                    setState(() {
                      SM.setShoppingListId(_shoppingListIdInput);
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('Zapisano ID Listy zakupów')));
                  },
                ),
              ],
            ));
  }

  Future<void> showEditUsernameDialog(BuildContext ctx) async {
    _usernameInput = SM.getUsername();
    await showDialog(
        context: ctx,
        builder: (ctx) => AlertDialog(
              title: Text('Nazwa użytkownika'),
              content: TextFormField(
                initialValue: SM.getUsername(),
                decoration: InputDecoration(label: Text('Wpisz nazwę...')),
                onChanged: (newValue) {
                  setState(() {
                    _usernameInput = newValue;
                  });
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Anuluj'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                TextButton(
                  child: Text('Zapisz'),
                  onPressed: () {
                    setState(() {
                      SM.setUsername(_usernameInput);
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('Zapisano nazwę użytkownika')));
                  },
                ),
              ],
            ));
  }

  /// Clicking the version label in debug model will cause
  /// update dialog to pop up
  Future<void> handleClickVersionLabel() async {
    if (!kDebugMode) {
      return;
    }
    final latestRelease = await Updater().getLatestReleaseId();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DownloadUpdateDialog(newVersionId: latestRelease),
    );
  }

  @override
  Widget build(BuildContext context) {
    String shoppingListId = SM.getShoppingListId();
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Ustawienia'),
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 8),
        children: <Widget>[
          SettingsGroupTitle(titleText: 'Lista zakupów'),
          ListTile(
            title: Text('ID Listy zakupów'),
            subtitle:
                Text(shoppingListId == '' ? 'Nie ustawione' : shoppingListId),
            leading: Icon(
              Icons.shopping_cart,
              color: Colors.black,
            ),
            titleAlignment: ListTileTitleAlignment.center,
            onTap: () => showEditShoppingListIdDialog(context),
          ),
          ListTile(
            title: Text('Nazwa użytkownika'),
            subtitle: Text(SM.getUsername()),
            leading: Icon(
              Icons.person,
              color: Colors.black,
            ),
            titleAlignment: ListTileTitleAlignment.center,
            onTap: () => showEditUsernameDialog(context),
          ),
          SwitchListTile(
            title: Text(
              'Ukrywaj produkty zadeklarowane przez innych',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            secondary: Icon(
              Icons.remove_red_eye,
              color: Colors.black,
            ),
            value: SM.getHideProductsOthersDeclared(),
            onChanged: (newValue) => setState(() {
              SM.setHideProductsOthersDeclared(newValue);
            }),
          ),
          SettingsGroupTitle(titleText: 'O aplikacji'),
          ListTile(
            title: Text('Wersja'),
            subtitle: Text(AppInfo.getVersion()),
            leading: Icon(
              Icons.info,
              color: Colors.black,
            ),
            titleAlignment: ListTileTitleAlignment.center,
            onTap: handleClickVersionLabel,
          ),
        ],
      ),
    );
  }
}
