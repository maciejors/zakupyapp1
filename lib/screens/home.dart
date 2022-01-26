import 'dart:async';
import 'dart:collection';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:zakupyapk/utils/storage_manager.dart';
import 'package:zakupyapk/widgets/main_drawer.dart';
import 'package:zakupyapk/widgets/product_editor_dialog.dart';
import 'package:zakupyapk/widgets/shopping_list_item.dart';
import 'package:zakupyapk/widgets/show_help.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late StreamSubscription dataStream;
  final Map<String, ShoppingListItem> shoppingList = LinkedHashMap();
  bool isDataReady = false;
  final db = FirebaseDatabase.instance.reference(); //TODO: AppCheck

  /// Name of the shop serving as a filter.<br>
  /// Wildcard values:
  /// * '' (empty string) - no filter,
  /// * '~' - show items with no shop specified.
  String filteredShop = '';

  void activateListeners() {
    dataStream = db.child('list').onValue.listen((event) {
      setState(() {
        if (event.snapshot.value == null) {
          return;
        }
        var data = event.snapshot.value as Map<Object?, Object?>;
        data.forEach((key, value) {
          String id = key as String;
          String productName = (value as Map)['name'];
          String shopName = value['shop'];
          String dateToDisplay = value['dateAddedToDisplay'];
          String whoAdded = value['whoAdded'];
          var newProduct = ShoppingListItem(
              id: id,
              name: productName,
              shop: shopName,
              dateAddedToDisplay: dateToDisplay,
              whoAdded: whoAdded,
              editFunc: () => editFunc(context,
                  productId: id,
                  whoAdded: whoAdded,
                  initialProductName: productName,
                  shopName: shopName),
              deleteFunc: () =>
                  deleteFunc(context, productId: id, productName: productName));
          shoppingList[id] = newProduct;
        });
        isDataReady = true;
      });
    });
  }

  void editFunc(BuildContext context,
      {required String productId,
      required String whoAdded,
      required String initialProductName,
      required String shopName}) {
    if (SM.getUserName() == whoAdded) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ProductEditorDialog(
                editingProduct: true,
                productId: productId,
                initialProductName: initialProductName,
                initialShopName: shopName,
              ));
    }
  }

  void deleteFunc(BuildContext context,
      {required String productId, required String productName}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Usuń produkt'),
          content: Text('Czy na pewno chcesz usunąć: $productName?'),
          actions: <Widget>[
            TextButton(
              child: Text('Anuluj'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Tak'),
              onPressed: () {
                db.child('list').child(productId).remove();
                shoppingList.remove(productId);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Usunięto wybrany produkt'),
                ));
              },
            ),
          ],
        );
      },
    );
  }

  /// Returns a filtered list of items to put inside the main ListView.
  List<Widget> getItemsToDisplay() {
    Iterable<ShoppingListItem> itemsToDisplay = shoppingList.values;
    if (filteredShop != '') {
      // there is a filter applied
      itemsToDisplay = itemsToDisplay.where((item) {
        if (filteredShop == '~') {
          return item.shop == '';
        }
        return item.shop == filteredShop;
      });
    }
    // reversed so that they appear in a chronological order
    return itemsToDisplay.toList().reversed.toList();
  }

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    activateListeners();
  }

  @override
  void deactivate() {
    super.deactivate();
    dataStream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> itemsToDisplay = getItemsToDisplay();
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Lista Zakupów'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () => showHelpDialog(context),
          ),
          PopupMenuButton(
            icon: Icon(Icons.filter_alt),
            itemBuilder: (BuildContext context) =>
                ShoppingListItem.allAvailableShops
                    .map((e) => PopupMenuItem(
                          child: Text(e),
                          value: e,
                        ))
                    .toList()
                      ..insert(
                          0,
                          PopupMenuItem(
                            child: Text('Wszystkie'),
                            value: '',
                          ))
                      ..insert(
                          1,
                          PopupMenuItem(
                            child: Text('Nieokreślone'),
                            value: '~',
                          )),
            onSelected: (newValue) {
              setState(() {
                filteredShop = newValue as String;
              });
            },
            initialValue: filteredShop,
          ),
        ],
      ),
      body: Scrollbar(
        child: !isDataReady
            ? Center(child: CircularProgressIndicator())
            : itemsToDisplay.isEmpty
                ? Center(
                    child: Text(
                    'Brak przedmiotów do wyświetlenia',
                    textAlign: TextAlign.center,
                  ))
                : ListView(
                    children: itemsToDisplay,
                    padding: EdgeInsets.all(5.0),
                  ),
      ),
      floatingActionButton: IgnorePointer(
        ignoring: !isDataReady,
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) =>
                    ProductEditorDialog(editingProduct: false));
          },
          child: Icon(
            Icons.add_shopping_cart,
          ),
        ),
      ),
    );
  }
}
