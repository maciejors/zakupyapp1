import 'dart:async';
import 'dart:collection';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:zakupyapk/core/deadline.dart';
import 'package:zakupyapk/core/product.dart';
import 'package:zakupyapk/utils/storage_manager.dart';
import 'package:zakupyapk/widgets/main_drawer.dart';
import 'package:zakupyapk/widgets/product_editor_dialog.dart';
import 'package:zakupyapk/widgets/product_card.dart';
import 'package:zakupyapk/widgets/show_help.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StreamSubscription dataStream;
  final Map<String, Product> shoppingList = LinkedHashMap();
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
        isDataReady = true;
        if (event.snapshot.value == null) {
          isDataReady = true;
          return;
        }
        var data = event.snapshot.value as Map<Object?, Object?>;
        data.forEach((key, value) {
          // TODO: move that to DatabaseManager
          String id = key as String;
          String productName = (value as Map)['name'];
          String whoAdded = value['whoAdded'];
          DateTime dateAdded = DateTime.parse(value['dateAdded']);
          String? shopName = value['shop'];
          Deadline? deadline;
          if (value['deadline'] != null) {
            deadline = Deadline.parse(value['deadline']);
          }
          var newProduct = Product(
              id: id,
              name: productName,
              shop: shopName,
              dateAdded: dateAdded,
              whoAdded: whoAdded,
              deadline: deadline);
          shoppingList[id] = newProduct;
        });
      });
    });
  }

  void editFunc(BuildContext context, {required String productId}) {
    Product item = shoppingList[productId]!;
    if (SM.getUserName() == item.whoAdded) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ProductEditorDialog(
                editingProduct: true,
                product: item,
              ));
    }
  }

  void deleteFunc(BuildContext context, {required String productId}) {
    Product item = shoppingList[productId]!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Usuń produkt'),
          content: Text('Czy na pewno chcesz usunąć: ${item.name}?'),
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
    Iterable<Product> products = shoppingList.values;
    if (filteredShop != '') {
      // there is a filter applied
      products = products.where((item) {
        if (filteredShop == '~') {
          return item.shop == null;
        }
        return item.shop == filteredShop;
      });
    }
    // create actual widgets from products
    Iterable<ProductCard> itemsToDisplay = products.map(wrapProductWithCard);
    // reversed so that they appear in a chronological order
    return itemsToDisplay.toList().reversed.toList();
  }

  ProductCard wrapProductWithCard(Product product) {
    return ProductCard(
        product: product,
        editFunc: () => editFunc(context, productId: product.id),
        deleteFunc: () => deleteFunc(context, productId: product.id));
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
            itemBuilder: (BuildContext context) => Product.allAvailableShops
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
