import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:zakupyapp/core/updater.dart';
import 'package:zakupyapp/services/storage_manager.dart';
import 'package:zakupyapp/services/auth_manager.dart';
import 'package:zakupyapp/utils/app_info.dart';
import 'package:zakupyapp/utils/snackbars.dart';
import 'package:zakupyapp/widgets/drawer/main_drawer.dart';
import 'package:zakupyapp/widgets/settings/setting_info_wrapper.dart';
import 'package:zakupyapp/widgets/settings/settings_group_title.dart';
import 'package:zakupyapp/widgets/shared/dismissible_help_dialog.dart';
import 'package:zakupyapp/widgets/shared/text_input_dialog.dart';
import 'package:zakupyapp/widgets/shared/update_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthManager auth = AuthManager.instance;

  Future<void> handleEditUsername(BuildContext ctx) async {
    if (!auth.isUserSignedIn) {
      // no point if not signed in
      return;
    }
    final currentUserName = auth.getUserDisplayName()!;
    String? newUserName = await showDialog(
      context: ctx,
      builder: (ctx) => TextInputDialog(
        title: const Text('Nazwa użytkownika'),
        confirmButtonChild: const Text('Zapisz'),
        initialValue: currentUserName,
        hintText: 'Wpisz nazwę...',
        validator: (String? userName) {
          if (userName == null || userName.length == 0) {
            return 'Nazwa nie może być pusta';
          }
          if (userName.length > 40) {
            return 'Wybrana nazwa jest za długa';
          }
          return null;
        },
      ),
    );
    // handle cancel
    if (newUserName == null) {
      return;
    }
    await auth.setUserDisplayName(newUserName);
    setState(() => newUserName);
    showSnackBar(
      context: context,
      content: const Text('Zapisano nazwę użytkownika'),
    );
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
        content: const Text(
          'Kliknij i przytrzymaj wybrane ustawienie, '
          'aby dowiedzieć się o nim więcej.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(isUserSignedIn: auth.isUserSignedIn),
      appBar: AppBar(
        title: const Text('Ustawienia'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.help,
              color: Colors.black,
            ),
            onPressed: showGeneralHelpDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8),
        children: <Widget>[
          const SettingsGroupTitle(title: const Text('Konto')),
          SettingInfoWrapper(
            child: ListTile(
              title: const Text('Nazwa użytkownika'),
              subtitle: Text(auth.getUserDisplayName() ?? 'Nie zalogowano'),
              leading: const Icon(
                Icons.person,
                color: Colors.black,
              ),
              titleAlignment: ListTileTitleAlignment.center,
              onTap: () => handleEditUsername(context),
              enabled: auth.isUserSignedIn,
            ),
            infoContent: const Text('Twoja nazwa, wyświetlana pod dodawanymi i '
                'edytowanymi przez Ciebie produktami.'),
          ),
          SettingInfoWrapper(
            child: ListTile(
              title: const Text('Wyloguj'),
              subtitle: Text(auth.getUserEmail() ?? 'Nie zalogowano'),
              leading: const Icon(
                Icons.logout,
                color: Colors.black,
              ),
              titleAlignment: ListTileTitleAlignment.center,
              onTap: () => handleSignOut(context),
              enabled: auth.isUserSignedIn,
            ),
            infoContent:
                const Text('Kliknięcie tej opcji spowoduje wylogowanie z '
                    'konta i przekierowanie na stronę główną aplikacji.'),
          ),
          const SettingsGroupTitle(title: const Text('Lista zakupów')),
          SettingInfoWrapper(
            child: SwitchListTile(
              title: const Text(
                'Ukrywaj produkty zadeklarowane przez innych',
                style: const TextStyle(color: Colors.black),
              ),
              secondary: const Icon(
                Icons.shopping_cart_checkout,
                color: Colors.black,
              ),
              value: SM.getHideProductsOthersDeclared(),
              onChanged: (newValue) => setState(() {
                SM.setHideProductsOthersDeclared(newValue);
              }),
            ),
            infoContent: const Text(
                'Jeśli ta opcja jest włączona, to produkty, '
                'które inni użytkownicy zamierzają kupić, nie będą się '
                'wyświetlać na liście zakupów. W przeciwnym razie na liście '
                'zakupów zawsze będą się wyświetlać wszystkie produkty.'),
          ),
          SettingInfoWrapper(
            child: SwitchListTile(
              title: const Text(
                'Ustawiaj domyślnie ilość przy dodawaniu produktu',
                style: TextStyle(color: Colors.black),
              ),
              secondary: const Icon(
                Icons.numbers,
                color: Colors.black,
              ),
              value: SM.getIsAutoQuantityEnabled(),
              onChanged: (newValue) => setState(() {
                SM.setIsAutoQuantityEnabled(newValue);
              }),
            ),
            infoContent: const Text(
                'Jeśli ta opcja jest włączona, to przy dodawaniu nowego '
                'produktu ilość będzie domyślnie ustawiona jako "1 szt.". '
                'W przeciwnym wypadku, ilość nie będzie w ogóle domyślnie '
                'ustawiona.'),
          ),
          const SettingsGroupTitle(title: const Text('O aplikacji')),
          ListTile(
            title: const Text('Wersja'),
            subtitle: Text(AppInfo.getVersion()),
            leading: const Icon(
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
