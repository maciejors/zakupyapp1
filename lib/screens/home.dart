import 'package:diffutil_sliverlist/diffutil_sliverlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'package:zakupyapp/core/models/product.dart';
import 'package:zakupyapp/core/shopping_list_manager.dart';
import 'package:zakupyapp/core/updater.dart';
import 'package:zakupyapp/storage/storage_manager.dart';
import 'package:zakupyapp/widgets/drawer/main_drawer.dart';
import 'package:zakupyapp/widgets/home/product_card/product_card.dart';
import 'package:zakupyapp/widgets/shared/update_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ShoppingListManager shoppingListManager =
      ShoppingListManager(SM.getShoppingListId());
  final Updater updater = Updater();

  List<Widget> itemsToDisplay = [];

  bool isFirstLoadDone = false;

  Product? editedProduct;
  bool isAddingProduct = false;

  /// Updates [editedProduct] & [isAddingProduct] flags and resets
  /// itemsToDisplay list to remove any editors. Doesn't call setState
  void hideEditor() {
    isAddingProduct = false;
    editedProduct = null;
    setItemsToDisplay(shoppingListManager.filteredProducts);
  }

  /*
  //
  ====== CARD CALLBACKS ======
  //
   */

  void addProductFunc() {
    if (!isAddingProduct) {
      setState(() {
        editedProduct = null;
        isAddingProduct = true;
        setItemsToDisplay(shoppingListManager.filteredProducts);
      });
    }
  }

  void editProductFunc(Product product) {
    if (product.isEditable)
      setState(() {
        isAddingProduct = false;
        editedProduct = product;
        setItemsToDisplay(shoppingListManager.filteredProducts);
      });
  }

  Future<void> deleteProductFunc(Product product) async {
    await shoppingListManager.removeProduct(product);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Usunięto wybrany produkt'),
    ));
  }

  Future<void> addBuyerFunc(Product product) async {
    bool? actionResult = await shoppingListManager.toggleProductBuyer(product);
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

  Future<void> confirmEditProductFunc(Product product) async {
    hideEditor();
    await shoppingListManager.storeProduct(product);
  }

  void cancelEditProductFunc() {
    setState(() => hideEditor());
  }

  /*
  //
  ====== FILTERS ======
  //
   */

  void toggleBuyerFilter() {
    // cancel editing when filters change
    hideEditor();
    // toggle filter
    shoppingListManager.showOnlyDeclaredByUser =
        !shoppingListManager.showOnlyDeclaredByUser;
  }

  void setShopFilter(String filter) {
    // cancel editing when filters change
    hideEditor();
    // apply filter
    shoppingListManager.filteredShop = filter;
  }

  /*
  //
  ====== UPDATING SHOPPING LIST ======
  //
   */

  /// Updates [itemsToDisplay] which stores a list of widgets to put inside the
  /// main list view.
  void setItemsToDisplay(List<Product> products) {
    // create actual widgets from products
    final result = products.map(wrapProductWithWidget).toList();

    // handle adding product
    if (isAddingProduct) {
      final defaults = Product(
        // default values for editor
        isVirtual: true,
        id: Product.generateProductId(),
        name: '',
        dateAdded: DateTime.now(),
        whoAdded: SM.getUsername(),
        // set shop by default if filter active
        shop: shoppingListManager.isShopFilterApplied
            ? shoppingListManager.filteredShop
            : null,
        // set buyer by default if filter active
        buyer: shoppingListManager.showOnlyDeclaredByUser
            ? SM.getUsername()
            : null,
        quantity: 1,
        quantityUnit: 'szt.',
      );
      final addProductCard = wrapProductWithWidget(defaults, isEditing: true);
      result.insert(0, addProductCard);
    }
    // handle editing product
    else if (editedProduct != null) {
      // substitute one of the product cards for the editable version
      final product = editedProduct!;
      int editedProductIndex = products.indexOf(product);
      result[editedProductIndex] = wrapProductWithWidget(
        product,
        isEditing: true,
      );
    }
    itemsToDisplay = result;
  }

  Widget wrapProductWithWidget(Product product, {bool isEditing = false}) {
    return ProductCard(
      key: Key(product.id),
      product: product,
      editFunc: () => editProductFunc(product),
      deleteFunc: deleteProductFunc,
      addBuyerFunc: () => addBuyerFunc(product),
      onConfirmEdit: confirmEditProductFunc,
      onCancelEdit: cancelEditProductFunc,
      isEditing: isEditing,
    );
  }

  /// Will run every time products list is updated
  void onProductsUpdated(List<Product> snapshot) {
    setState(() {
      isFirstLoadDone = true;
      setItemsToDisplay(snapshot);
    });
  }

  /*
  //
  ====== LIFECYCLE METHODS ======
  //
   */

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
    if (shoppingListManager.isInitialised) {
      shoppingListManager.onProductsUpdated = onProductsUpdated;
      shoppingListManager.onDefaultShopsReveived = () => setState(() {
            // empty setState to refresh filters with contents of
            // shoppingListManager.availableShops
          });
      shoppingListManager.subscribe();
    }
  }

  @override
  void dispose() {
    shoppingListManager.unsubscribe();
    super.dispose();
  }

  /*
  //
  ====== WIDGET TREE ======
  //
   */

  /// different body depending on [isFirstLoadDone] &
  /// [shoppingListManager.isInitialised] values
  Widget getBody() {
    // if shoppingListId is not specified, display an info on it
    if (!shoppingListManager.isInitialised)
      return Center(
          child: Text(
        'Nie wybrano żadnej listy zakupów. Możesz to zrobić w Ustawieniach',
        textAlign: TextAlign.center,
      ));

    // if shoppingListId is specified, but the data is loading, display
    // a circular progress indicator
    if (!isFirstLoadDone) return Center(child: CircularProgressIndicator());

    // for content shown if itemsToDisplay.isEmpty
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).viewPadding;
    final viewHeight = screenHeight - padding.top - kToolbarHeight;

    // otherwise, display the shopping list
    return Provider<ShoppingListManager>(
      create: (context) => shoppingListManager,
      child: CustomScrollView(
        slivers: [
          DiffUtilSliverList.fromKeyedWidgetList(
            children: List.from(itemsToDisplay),
            insertAnimationBuilder: (context, animation, child) =>
                FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: 1,
                child: child,
              ),
            ),
            removeAnimationBuilder: (context, animation, child) =>
                FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: 1,
                child: child,
              ),
            ),
          ),
          if (itemsToDisplay.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                height: viewHeight,
                child: Center(
                    child: Text(
                  'Brak przedmiotów do wyświetlenia',
                  textAlign: TextAlign.center,
                )),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Lista zakupów'),
        actions: !isFirstLoadDone
            ? []
            : <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.shopping_cart_checkout,
                    color: shoppingListManager.showOnlyDeclaredByUser
                        ? Colors.black
                        : Colors.deepOrange[900],
                  ),
                  onPressed: toggleBuyerFilter,
                ),
                PopupMenuButton(
                  icon: Icon(
                    Icons.filter_alt,
                    color: shoppingListManager.isShopFilterApplied
                        ? Colors.black
                        : Colors.deepOrange[900],
                  ),
                  itemBuilder: (BuildContext context) =>
                      shoppingListManager.filterableShops
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
                  initialValue: shoppingListManager.filteredShop,
                ),
              ],
      ),
      body: getBody(),
      floatingActionButton: Visibility(
        visible: isFirstLoadDone && !isAddingProduct,
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
