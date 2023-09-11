import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:zakupyapp/core/models/product.dart';
import 'package:zakupyapp/core/shopping_list.dart';
import 'package:zakupyapp/core/updater.dart';
import 'package:zakupyapp/widgets/drawer/main_drawer.dart';
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

  Product? editedProduct;
  bool addingProduct = false;

  void addProductFunc() {
    if (!addingProduct) {
      setState(() {
        editedProduct = null;
        addingProduct = true;
      });
    }
  }

  void Function() getEditProductFunc(Product product) {
    return () {
      if (product.isEditable)
        setState(() {
          addingProduct = false;
          editedProduct = product;
        });
    };
  }

  void Function() getDeleteProductFunc(Product product) {
    return () async => await showDialog(
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

  void Function() getAddBuyerFunc(Product product) {
    return () async {
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
    };
  }

  void toggleBuyerFilter() {
    setState(() {
      // cancel editing when filters change
      editedProduct = null;
      // toggle filter
      shoppingList.showOnlyDeclaredByUser =
          !shoppingList.showOnlyDeclaredByUser;
    });
  }

  void setShopFilter(String filter) {
    setState(() {
      // cancel editing when filters change
      editedProduct = null;
      // apply filter
      shoppingList.filteredShop = filter;
    });
  }

  /// Returns a list of widgets to put inside the main ListView.
  List<Widget> getItemsToDisplay() {
    // create actual widgets from products
    final products = shoppingList.getProductsToDisplay();
    final result = products.map(wrapProductWithCard).toList();

    // handle adding product
    if (addingProduct) {
      // adding product key
      final productCard = ProductCard(
        key: Key('adding'),
        product: null,
        editFunc: () {},
        deleteFunc: () {},
        addBuyerFunc: () {},
        isEditing: true,
      );
      result.insert(0, productCard);
    }

    // handle editing product
    else if (editedProduct != null) {
      // substitute one of the product cards for the editable version
      final product = editedProduct!;
      int editedProductIndex = products.indexOf(product);
      result[editedProductIndex] = wrapProductWithCard(
        product,
        key: Key('e${product.id}'),
        isEditing: true,
      );
    }
    return result;
  }

  ProductCard wrapProductWithCard(Product product,
      {Key? key, bool isEditing = false}) {
    if (key == null) {
      key = Key(product.id);
    }
    return ProductCard(
      key: key,
      product: product,
      editFunc: getEditProductFunc(product),
      deleteFunc: getDeleteProductFunc(product),
      addBuyerFunc: getAddBuyerFunc(product),
      isEditing: isEditing,
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
            onPressed: toggleBuyerFilter,
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
            onSelected: setShopFilter,
            initialValue: shoppingList.filteredShop,
          ),
        ],
      ),
      body: getBody(),
      floatingActionButton: Visibility(
        visible: isDataReady,
        child: FloatingActionButton(
          onPressed: addProductFunc,
          child: Icon(
            Icons.add_shopping_cart,
          ),
        ),
      ),
    );
  }
}
