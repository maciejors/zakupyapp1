import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:zakupyapp/core/updater.dart';
import 'package:zakupyapp/services/storage_manager.dart';
import 'package:zakupyapp/services/auth_manager.dart';
import 'package:zakupyapp/utils/app_info.dart';
import 'package:zakupyapp/widgets/drawer/main_drawer.dart';
import 'package:zakupyapp/widgets/settings/setting_info_wrapper.dart';
import 'package:zakupyapp/widgets/settings/settings_group_title.dart';
import 'package:zakupyapp/widgets/shared/dismissible_help_dialog.dart';
import 'package:zakupyapp/widgets/shared/update_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthManager auth = AuthManager.instance;

  String _shoppingListIdInput = '';
  String _userNameInput = '';

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
    if (!auth.isUserSignedIn) {
      // no point if not signed in
      return;
    }
    final currentUserName = auth.getUserDisplayName()!;
    _userNameInput = currentUserName;
    await showDialog(
        context: ctx,
        builder: (ctx) => AlertDialog(
              title: Text('Nazwa użytkownika'),
              content: TextFormField(
                initialValue: currentUserName,
                decoration: InputDecoration(label: Text('Wpisz nazwę...')),
                onChanged: (newValue) {
                  setState(() {
                    _userNameInput = newValue;
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
                    auth
                        .setUserDisplayName(_userNameInput)
                        .then((newUserName) => setState(() {}));
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Zapisano nazwę użytkownika')),
                    );
                  },
                ),
              ],
            ));
  }

  Future<void> handleSignOut(BuildContext ctx) async {
    await auth.signOut();
    Navigator.of(ctx).pushReplacementNamed('/');
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

  /// Show a help dialog for the settings screen
  Future<void> showGeneralHelpDialog() async {
    await showDialog(
      context: context,
      builder: (ctx) => DismissibleHelpDialog(
        content: Text(
          'Kliknij i przytrzymaj wybrane ustawienie, '
          'aby dowiedzieć się o nim więcej',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String shoppingListId = SM.getShoppingListId();
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Ustawienia'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.help,
              color: Colors.black,
            ),
            onPressed: showGeneralHelpDialog,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 8),
        children: <Widget>[
          SettingsGroupTitle(titleText: 'Konto'),
          ListTile(
            title: Text('Nazwa użytkownika'),
            subtitle: Text(auth.getUserDisplayName() ?? 'Nie zalogowano'),
            leading: Icon(
              Icons.person,
              color: Colors.black,
            ),
            titleAlignment: ListTileTitleAlignment.center,
            onTap: () => showEditUsernameDialog(context),
            enabled: auth.isUserSignedIn,
          ),
          ListTile(
            title: Text('Wyloguj'),
            subtitle: Text(auth.getUserEmail() ?? 'Nie zalogowano'),
            leading: Icon(
              Icons.logout,
              color: Colors.black,
            ),
            titleAlignment: ListTileTitleAlignment.center,
            onTap: () => handleSignOut(context),
            enabled: auth.isUserSignedIn,
          ),
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
          SettingInfoWrapper(
            child: SwitchListTile(
              title: Text(
                'Ukrywaj produkty zadeklarowane przez innych',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              secondary: Icon(
                Icons.shopping_cart_checkout,
                color: Colors.black,
              ),
              value: SM.getHideProductsOthersDeclared(),
              onChanged: (newValue) => setState(() {
                SM.setHideProductsOthersDeclared(newValue);
              }),
            ),
            infoContent: Text('Jeśli ta opcja jest włączona, to produkty, '
                'które inni użytkownicy zamierzają kupić, nie będą się '
                'wyświetlać na liście zakupów. W przeciwnym razie na liście '
                'zakupów zawsze będą się wyświetlać wszystkie produkty.'),
          ),
          SettingInfoWrapper(
            child: SwitchListTile(
              title: Text(
                'Ustawiaj domyślnie ilość przy dodawaniu produktu',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              secondary: Icon(
                Icons.numbers,
                color: Colors.black,
              ),
              value: SM.getIsAutoQuantityEnabled(),
              onChanged: (newValue) => setState(() {
                SM.setIsAutoQuantityEnabled(newValue);
              }),
            ),
            infoContent:
                Text('Jeśli ta opcja jest włączona, to przy dodawaniu nowego '
                    'produktu ilość będzie domyślnie ustawiona jako "1 szt.". '
                    'W przeciwnym wypadku, ilość nie będzie w ogóle domyślnie '
                    'ustawiona.'),
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
