import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:zakupyapp/core/models/product.dart';
import 'package:zakupyapp/core/shopping_list.dart';
import 'package:zakupyapp/core/updater.dart';
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
  ShoppingList shoppingList = ShoppingList();
  Updater updater = Updater();
  bool isDataReady = false;

  /// Used to wrap functions passed to the onPressed property
  /// in buttons to disable them if the data is not ready yet
  void Function()? disableIfDataNotReady(void Function() func) {
    return isDataReady ? func : null;
  }

  Future<void> editFunc(BuildContext context,
      {required Product product}) async {
    if (product.isEditable) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ProductEditorDialog(
                editingProduct: true,
                product: product,
                shoppingList: shoppingList,
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
                await shoppingList.removeProduct(product);
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
    bool? actionResult = await shoppingList.toggleProductBuyer(product);
    // no action was taken
    if (actionResult == null) {
      return;
    }
    // buyer added
    if (actionResult) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Dodano deklarację kupna'),
      ));
    }
    // buyer removed
    else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Usunięto deklarację kupna'),
      ));
    }
  }

  /// Returns a list of widgets to put inside the main ListView.
  List<Widget> getItemsToDisplay() {
    // create actual widgets from products
    return shoppingList
        .getProductsToDisplay()
        .map(wrapProductWithCard)
        .toList();
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

  /// different body depending on
  /// [isDataReady] & [shoppingList.isInitialised] values
  Widget getBody() {
    // if shoppingListId is not specified, display an info on it
    if (!shoppingList.isInitialised)
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
    SchedulerBinding.instance
        .addPostFrameCallback((_) => updater.checkForUpdate((release) async =>
            // show update dialog
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => DownloadUpdateDialog(release: release),
            )));

    // initialise the shopping list
    if (shoppingList.isInitialised) {
      shoppingList.startListening(() {
        // on new products refresh the view as well as update isDataReady flag
        setState(() {
          isDataReady = true;
        });
      });
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    shoppingList.stopListening();
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
              color: shoppingList.showOnlyDeclaredByUser
                  ? Colors.black
                  : Colors.deepOrange[900],
            ),
            onPressed: () {
              setState(() {
                shoppingList.showOnlyDeclaredByUser =
                    !shoppingList.showOnlyDeclaredByUser;
              });
            },
          ),
          PopupMenuButton(
            enabled: isDataReady,
            icon: Icon(
              Icons.filter_alt,
              color: shoppingList.shopFilterApplied
                  ? Colors.black
                  : Colors.deepOrange[900],
            ),
            itemBuilder: (BuildContext context) =>
                shoppingList.allAvailableShops
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
                shoppingList.filteredShop = newValue;
              });
            },
            initialValue: shoppingList.filteredShop,
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
                builder: (context) => ProductEditorDialog(
                      editingProduct: false,
                      shoppingList: shoppingList,
                    ));
          }),
          child: Icon(
            Icons.add_shopping_cart,
          ),
        ),
      ),
    );
  }
}
