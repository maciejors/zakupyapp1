import 'package:flutter/material.dart';
import 'package:zakupyapk/utils/date_time_functions.dart';
import 'package:zakupyapk/utils/storage_manager.dart';
import 'package:zakupyapk/widgets/main_drawer.dart';
import 'package:zakupyapk/widgets/shopping_list_item.dart';
import 'package:zakupyapk/widgets/text_with_icon.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String username = SM.getUserName();
  double mainFontSize = SM.getMainFontSize();

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
            text: 'Nazwa użytkownika:',
            iconData: Icons.account_circle,
            color: Colors.orange,
            size: SM.getMainFontSize() * 1.5,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: TextFormField(
              initialValue: SM.getUserName(),
              decoration: InputDecoration(
                hintText: 'Wpisz nazwę...'
              ),
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
          ShoppingListItem(
            id: '',
            name: 'Przykładowa nazwa produktu',
            shop: 'Przykładowy',
            dateAddedToDisplay: dateTimeToString(DateTime.now()),
            whoAdded: username,
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
