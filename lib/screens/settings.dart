import 'package:flutter/material.dart';
import 'package:zakupyapk/core/product.dart';
import 'package:zakupyapk/utils/storage_manager.dart';
import 'package:zakupyapk/widgets/main_drawer.dart';
import 'package:zakupyapk/widgets/product_card.dart';
import 'package:zakupyapk/widgets/text_with_icon.dart';

import '../utils/database_manager.dart';
import '../widgets/update_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String username = SM.getUserName();
  double mainFontSize = SM.getMainFontSize();
  final db = DatabaseManager.instance;

  void handleUpdateCheck(BuildContext ctx) {
    // show loading
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator()],
        ),
      ),
    );

    db.isUpdateAvailable().then((value) {
      if (!value) {
        // hide loading
        Navigator.of(ctx).pop();
        // display info
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text('Nie ma dostępnych aktualizacji'),
        ));
      } else {
        // retrieve the latest release info
        db.getLatestRelease().then((release) {
          // hide loading
          Navigator.of(ctx).pop();
          // show update dialog
          showDialog(
            context: ctx,
            barrierDismissible: false,
            builder: (ctx) => DownloadUpdateDialog(
              latestRelease: release,
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Ustawienia'),
      ),
      body: ListView(
        padding: EdgeInsets.all(5.0),
        children: <Widget>[
          SizedBox(height: 5),
          SimpleTextWithIcon(
            text: 'Aktualizacje',
            iconData: Icons.download,
            color: Colors.orange,
            size: SM.getMainFontSize() * 1.5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  handleUpdateCheck(context);
                },
                child: Text('Sprawdź dostępność aktualizacji'),
              ),
            ],
          ),
          SizedBox(height: SM.getMainFontSize()),
          SimpleTextWithIcon(
            text: 'Nazwa użytkownika:',
            iconData: Icons.account_circle,
            color: Colors.orange,
            size: SM.getMainFontSize() * 1.5,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: TextFormField(
              initialValue: SM.getUserName(),
              decoration: InputDecoration(hintText: 'Wpisz nazwę...'),
              onChanged: (newValue) {
                setState(() {
                  username = newValue;
                });
              },
            ),
          ),
          SizedBox(height: SM.getMainFontSize()),
          SimpleTextWithIcon(
            text: 'Rozmiar Czcionki:',
            iconData: Icons.format_size,
            color: Colors.orange,
            size: SM.getMainFontSize() * 1.5,
          ),
          Slider(
            value: mainFontSize,
            onChanged: (newValue) {
              setState(() {
                mainFontSize = newValue;
              });
            },
            min: 10,
            max: 30,
            divisions: 20,
            label: mainFontSize.toInt().toString(),
          ),
          SizedBox(height: SM.getMainFontSize()),
          SimpleTextWithIcon(
            text: 'Podgląd karty produktu:',
            iconData: Icons.preview,
            color: Colors.orange,
            size: SM.getMainFontSize() * 1.5,
          ),
          ProductCard(
            product: Product(
              id: '',
              name: 'Przykładowa nazwa produktu',
              shop: 'Przykładowy',
              dateAdded: DateTime.now(),
              whoAdded: username,
            ),
            editFunc: () {},
            deleteFunc: () {},
            mainFontSize: mainFontSize,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          final FocusScopeNode currentScope = FocusScope.of(context);
          if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
            FocusManager.instance.primaryFocus!.unfocus();
          }
          setState(() {
            SM.setMainFontSize(mainFontSize);
            SM.setUserName(username);
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Zapisano ustawienia'),
          ));
        },
      ),
    );
  }
}
