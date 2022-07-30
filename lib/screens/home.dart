import 'package:flutter/material.dart';
import 'package:zakupyapk/core/product.dart';
import 'package:zakupyapk/storage/database_manager.dart';
import 'package:zakupyapk/storage/storage_manager.dart';
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
  final db = DatabaseManager.instance;
  List<Product> shoppingList = [];
  bool isDataReady = false;

  /// Name of the shop serving as a filter.<br>
  /// Wildcard values:
  /// * '' (empty string) - no filter,
  /// * '~' - show items with no shop specified.
  String filteredShop = '';

  /// Used to wrap functions passed to the onPressed property
  /// in buttons to disable them if the data is not ready yet
  void Function()? disableIfDataNotReady(void Function() func) {
    return isDataReady ? func : null;
  }

  void editFunc(BuildContext context, {required Product product}) {
    if (SM.getUserName() == product.whoAdded) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ProductEditorDialog(
                editingProduct: true,
                product: product,
              ));
    }
  }

  void deleteFunc(BuildContext context, {required Product product}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Usuń produkt'),
          content: Text('Czy na pewno chcesz usunąć: ${product.name}?'),
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
                db.removeProduct(product.id);
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
    Iterable<Product> products = [...shoppingList];
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
    return itemsToDisplay.toList();
  }

  ProductCard wrapProductWithCard(Product product) {
    return ProductCard(
        product: product,
        editFunc: () => editFunc(context, product: product),
        deleteFunc: () => deleteFunc(context, product: product));
  }

  @override
  void initState() {
    super.initState();
    db.setShoppingList('dev');
    db.setupListener((shoppingList) {
      setState(() {
        shoppingList.sort((p1, p2) => p2.dateAdded.compareTo(p1.dateAdded));
        this.shoppingList = shoppingList;
        isDataReady = true;
      });
    });
  }

  @override
  void deactivate() {
    super.deactivate();
    db.cancelListener();
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
            onPressed: disableIfDataNotReady(() => showHelpDialog(context)),
          ),
          PopupMenuButton(
            enabled: isDataReady,
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
      floatingActionButton: Visibility(
        visible: isDataReady,
        child: FloatingActionButton(
          onPressed: disableIfDataNotReady(() {
            showDialog(
                context: context,
                builder: (context) =>
                    ProductEditorDialog(editingProduct: false));
          }),
          child: Icon(
            Icons.add_shopping_cart,
          ),
        ),
      ),
    );
  }
}
