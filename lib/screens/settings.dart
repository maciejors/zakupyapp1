import 'package:flutter/material.dart';

import 'package:zakupyapp/storage/storage_manager.dart';
import 'package:zakupyapp/utils/app_info.dart';
import 'package:zakupyapp/widgets/main_drawer.dart';

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

  @override
  Widget build(BuildContext context) {
    String shoppingListId = SM.getShoppingListId();
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Ustawienia'),
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 5),
        children: <Widget>[
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
              'Sprawdzaj aktualizacje',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            secondary: Icon(
              Icons.update,
              color: Colors.black,
            ),
            value: SM.getCheckForUpdatesFlag(),
            onChanged: (newValue) => setState(() {
              SM.setCheckForUpdatesFlag(newValue);
            }),
          ),
          SwitchListTile(
            title: Text(
              'Wyświetlaj produkty zadeklarowane przez innych',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            secondary: Icon(
              Icons.remove_red_eye,
              color: Colors.black,
            ),
            value: SM.getDisplayDeclaredProductsFlag(),
            onChanged: (newValue) => setState(() {
              SM.setDisplayDeclaredProductsFlag(newValue);
            }),
          ),
          ListTile(
            title: Text('Wersja aplikacji'),
            subtitle: Text(AppInfo.getVersion()),
            leading: Icon(
              Icons.info,
              color: Colors.black,
            ),
            titleAlignment: ListTileTitleAlignment.center,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
