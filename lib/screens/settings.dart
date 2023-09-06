import 'package:flutter/material.dart';

import 'package:zakupyapp/core/product.dart';
import 'package:zakupyapp/storage/storage_manager.dart';
import 'package:zakupyapp/widgets/main_drawer.dart';
import 'package:zakupyapp/widgets/product_card.dart';
import 'package:zakupyapp/widgets/text_with_icon.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String shoppingListId = SM.getShoppingListId();
  String username = SM.getUsername();
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
            text: 'ID Listy zakupów:',
            iconData: Icons.shopping_cart,
            color: Colors.orange,
            size: SM.getMainFontSize() * 1.5,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: TextFormField(
              initialValue: SM.getShoppingListId(),
              decoration: InputDecoration(hintText: 'Wpisz ID...'),
              onChanged: (newValue) {
                setState(() {
                  shoppingListId = newValue;
                });
              },
            ),
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
              initialValue: SM.getUsername(),
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
            addBuyerFunc: () {},
            mainFontSize: mainFontSize,
            username: '',
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
            SM.setShoppingListId(shoppingListId);
            SM.setUserName(username);
            SM.setMainFontSize(mainFontSize);
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Zapisano ustawienia'),
          ));
        },
      ),
    );
  }
}
