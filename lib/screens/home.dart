import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'package:zakupyapp/core/models/product.dart';
import 'package:zakupyapp/core/shopping_list.dart';
import 'package:zakupyapp/core/updater.dart';
import 'package:zakupyapp/widgets/drawer/main_drawer.dart';
import 'package:zakupyapp/widgets/home/product_card/product_card.dart';
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
  bool isAddingProduct = false;

  void addProductFunc() {
    if (!isAddingProduct) {
      setState(() {
        editedProduct = null;
        isAddingProduct = true;
      });
    }
  }

  VoidCallback getEditProductFunc(Product product) {
    return () {
      if (product.isEditable)
        setState(() {
          isAddingProduct = false;
          editedProduct = product;
        });
    };
  }

  VoidCallback getDeleteProductFunc(Product product) =>
      () async => await showDialog(
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

  VoidCallback getAddBuyerFunc(Product product) => () async {
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

  Future<void> confirmEditProductFunc(Product product) async {
    setState(() {
      editedProduct = null;
      isAddingProduct = false;
    });
    await shoppingList.storeProduct(product);
  }

  void cancelEditProductFunc() {
    setState(() {
      editedProduct = null;
      isAddingProduct = false;
    });
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
    if (isAddingProduct) {
      // adding product key
      final productCard = ProductCard(
        key: Key('adding'),
        product: null,
        editFunc: () {},
        deleteFunc: () {},
        addBuyerFunc: () {},
        onConfirmEdit: confirmEditProductFunc,
        onCancelEdit: cancelEditProductFunc,
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
        isEditing: true,
      );
    }
    return result;
  }

  ProductCard wrapProductWithCard(Product product, {bool isEditing = false}) {
    return ProductCard(
      key: Key(product.id),
      product: product,
      editFunc: getEditProductFunc(product),
      deleteFunc: getDeleteProductFunc(product),
      addBuyerFunc: getAddBuyerFunc(product),
      onConfirmEdit: confirmEditProductFunc,
      onCancelEdit: cancelEditProductFunc,
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
    // also check if no product is added (otherwise products can't be added
    // when the list is empty
    if (shoppingList.isEmpty && !isAddingProduct)
      return Center(
          child: Text(
        'Brak przedmiotów do wyświetlenia',
        textAlign: TextAlign.center,
      ));

    // otherwise, display the shopping list
    return Scrollbar(
      child: Provider<ShoppingList>(
        create: (context) => shoppingList,
        builder: (context, child) => ListView(
          children: getItemsToDisplay(),
          padding: EdgeInsets.all(5.0),
        ),
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
      // on new products refresh the view as well as update isDataReady flag
      // on default shops received refresh the view so that the filters work
      shoppingList.startListening(
        onProductsUpdatedCallback: () => setState(() => isDataReady = true),
        onDefaultShopsReveivedCallback: () => setState(() {}),
      );
    }
  }

  @override
  void dispose() {
    shoppingList.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Lista Zakupów'),
        actions: !isDataReady
            ? []
            : <Widget>[
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
                  icon: Icon(
                    Icons.filter_alt,
                    color: shoppingList.shopFilterApplied
                        ? Colors.black
                        : Colors.deepOrange[900],
                  ),
                  itemBuilder: (BuildContext context) =>
                      shoppingList.availableShops
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
