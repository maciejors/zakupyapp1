import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:zakupyapp/core/product.dart';
import 'package:zakupyapp/storage/database_manager.dart';
import 'package:zakupyapp/storage/storage_manager.dart';
import 'package:zakupyapp/widgets/drawer/main_drawer.dart';
import 'package:zakupyapp/widgets/home/product_editor_dialog.dart';
import 'package:zakupyapp/widgets/home/product_card.dart';
import 'package:zakupyapp/widgets/home/update_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = DatabaseManager.instance;
  List<Product> shoppingList = [];
  bool isDataReady = false;
  String shoppingListId = SM.getShoppingListId();

  // this flag is necessary to prevent checking for update every time the
  // product list gets updates
  bool checkedForUpdate = false;

  bool showOnlyDeclaredByUser = false;

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

  Future<void> editFunc(BuildContext context,
      {required Product product}) async {
    if (SM.getUsername() == product.whoAdded) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ProductEditorDialog(
                editingProduct: true,
                product: product,
              ));
    }
  }

  Future<void> deleteFunc(BuildContext context,
      {required Product product}) async {
    await showDialog(
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
              onPressed: () async {
                await db.removeProduct(product.id);
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

  Future<void> addBuyerFunc(BuildContext context,
      {required Product product}) async {
    String username = SM.getUsername();

    if (product.buyer == null) {
      db.setProductBuyer(product.id, username);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Dodano deklarację kupna'),
      ));
    } else if (product.buyer == username) {
      db.setProductBuyer(product.id, null);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Dodano deklarację kupna'),
      ));
    }
  }

  void checkForUpdate() {
    db.isUpdateAvailable().then((value) {
      if (value) {
        // retrieve the latest release info
        db.getLatestRelease().then((release) {
          // show update dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => DownloadUpdateDialog(
              latestRelease: release,
            ),
          );
        });
      }
    });
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
    if (showOnlyDeclaredByUser) {
      products = products
          .where((p) => p.buyer == SM.getUsername())
          .toList();
    }
    // create actual widgets from products
    Iterable<ProductCard> itemsToDisplay = products.map(wrapProductWithCard);
    return itemsToDisplay.toList();
  }

  ProductCard wrapProductWithCard(Product product) {
    return ProductCard(
      product: product,
      editFunc: () async => await editFunc(context, product: product),
      deleteFunc: () async => await deleteFunc(context, product: product),
      addBuyerFunc: () async => await addBuyerFunc(context, product: product),
      username: SM.getUsername(),
    );
  }

  /// different body depending on [isDataReady] & [shoppingListId] values
  Widget getBody() {
    // if shoppingListId is not specified, display an info on it
    if (shoppingListId == '')
      return Center(
          child: Text(
        'Nie wybrano żadnej listy zakupów. Możesz to zrobić w Ustawieniach',
        textAlign: TextAlign.center,
      ));

    // if shoppingListId is specified, but the data is loading, display
    // a circular progress indicator
    if (!isDataReady) return Center(child: CircularProgressIndicator());

    // if data is ready, but the shopping list is empty, display an info on it
    if (shoppingList.isEmpty)
      return Center(
          child: Text(
        'Brak przedmiotów do wyświetlenia',
        textAlign: TextAlign.center,
      ));

    // otherwise, display the shopping list
    return Scrollbar(
      child: ListView(
        children: getItemsToDisplay(),
        padding: EdgeInsets.all(5.0),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // check for updates
    if (kReleaseMode && SM.getCheckForUpdatesFlag()) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        checkForUpdate();
      });
    }

    // initialise the shopping list
    if (shoppingListId != '') {
      db.setShoppingList(shoppingListId);
      db.setupListener((shoppingList) {
        setState(() {
          shoppingList.sort((p1, p2) => p2.dateAdded.compareTo(p1.dateAdded));
          // check if user wants to see products that others declared to buy
          if (SM.getHideProductsOthersDeclaredFlag()) {
            shoppingList = shoppingList
                .where((p) => p.buyer == null || p.buyer == SM.getUsername())
                .toList();
          }
          this.shoppingList = shoppingList;
          isDataReady = true;
        });
      });
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    db.cancelListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Lista Zakupów'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.shopping_cart_checkout,
              color: showOnlyDeclaredByUser
                  ? Colors.black
                  : Colors.deepOrange[900],
            ),
            onPressed: () {
              setState(() {
                showOnlyDeclaredByUser = !showOnlyDeclaredByUser;
              });
            },
          ),
          PopupMenuButton(
            enabled: isDataReady,
            icon: Icon(
              Icons.filter_alt,
              color: filteredShop != '' ? Colors.black : Colors.deepOrange[900],
            ),
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
                filteredShop = newValue;
              });
            },
            initialValue: filteredShop,
          ),
        ],
      ),
      body: getBody(),
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
