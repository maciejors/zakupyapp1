import 'package:diffutil_sliverlist/diffutil_sliverlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'package:zakupyapp/core/models/product.dart';
import 'package:zakupyapp/core/shopping_list_controller.dart';
import 'package:zakupyapp/core/updater.dart';
import 'package:zakupyapp/services/storage_manager.dart';
import 'package:zakupyapp/services/auth_manager.dart';
import 'package:zakupyapp/utils/snackbars.dart';
import 'package:zakupyapp/widgets/drawer/main_drawer.dart';
import 'package:zakupyapp/widgets/home/product_card/product_card.dart';
import 'package:zakupyapp/widgets/shared/full_screen_info.dart';
import 'package:zakupyapp/widgets/shared/loading.dart';
import 'package:zakupyapp/widgets/shared/update_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ShoppingListController shoppingListController =
      ShoppingListController(SM.getShoppingListId());
  final Updater updater = Updater();
  final AuthManager auth = AuthManager.instance;

  bool? isUserSignedIn = null;

  /// whether the process of logging in is going on
  bool isCurrentlySigningIn = false;
  bool isFirstLoadDone = false;

  List<Widget> itemsToDisplay = [];

  Product? editedProduct;
  bool isAddingProduct = false;

  /// Updates [editedProduct] & [isAddingProduct] flags and resets
  /// itemsToDisplay list to remove any editors. Doesn't call setState
  void hideEditor() {
    isAddingProduct = false;
    editedProduct = null;
    setItemsToDisplay(shoppingListController.filteredProducts);
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
        setItemsToDisplay(shoppingListController.filteredProducts);
      });
    }
  }

  void editProductFunc(Product product) {
    if (product.isEditable)
      setState(() {
        isAddingProduct = false;
        editedProduct = product;
        setItemsToDisplay(shoppingListController.filteredProducts);
      });
  }

  Future<void> deleteProductFunc(Product product) async {
    await shoppingListController.removeProduct(product);
    showSnackBar(
      context: context,
      content: const Text('Usunięto wybrany produkt'),
    );
  }

  Future<void> addBuyerFunc(Product product) async {
    bool? actionResult = await shoppingListController.toggleProductBuyer(product);
    // no action was taken
    if (actionResult == null) {
      return;
    }
    // buyer added
    if (actionResult) {
      showSnackBar(
        context: context,
        content: const Text('Dodano deklarację kupna'),
      );
    }
    // buyer removed
    else {
      showSnackBar(
        context: context,
        content: const Text('Usunięto deklarację kupna'),
      );
    }
  }

  Future<void> confirmEditProductFunc(Product product) async {
    hideEditor();
    await shoppingListController.storeProduct(product);
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
    shoppingListController.showOnlyDeclaredByUser =
        !shoppingListController.showOnlyDeclaredByUser;
  }

  void setShopFilter(String filter) {
    // cancel editing when filters change
    hideEditor();
    // apply filter
    shoppingListController.filteredShop = filter;
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
        authorName: auth.getUserDisplayName()!,
        authorEmail: auth.getUserEmail()!,
        // set shop by default if filter active
        shop: shoppingListController.isShopFilterApplied
            ? shoppingListController.filteredShop
            : null,
        // set buyer by default if filter active
        buyer: shoppingListController.showOnlyDeclaredByUser
            ? auth.getUserDisplayName()
            : null,
        quantity: SM.getIsAutoQuantityEnabled() ? 1 : null,
        quantityUnit: SM.getIsAutoQuantityEnabled() ? 'szt.' : null,
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
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => updater.checkForUpdate((newVersionId) async =>
          // show update dialog
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => DownloadUpdateDialog(newVersionId: newVersionId),
          )),
    );

    // listen to auth state changes
    auth.setupAuthStateListener((bool isSignedIn) {
      setState(() => isUserSignedIn = isSignedIn);
      // initialise the shopping list if a user is signed in
      if (isSignedIn) {
        if (shoppingListController.isInitialised) {
          shoppingListController.onProductsUpdated = onProductsUpdated;
          shoppingListController.onDefaultShopsReveived = () => setState(() {
                // empty setState to refresh filters with contents of
                // shoppingListManager.availableShops
              });
          shoppingListController.onPermissionDenied = () => setState(() {
            // reset shopping list ID on permission denied
            // (means that the user was removed from his list)
            SM.setShoppingListId('');
          });
          shoppingListController.subscribe();
        }
      }
    });
  }

  @override
  void dispose() {
    auth.cancelAuthStateListener();
    shoppingListController.unsubscribe();
    super.dispose();
  }

  /*
  //
  ====== WIDGET TREE ======
  //
   */

  /// different body depending on [isFirstLoadDone] &
  /// [shoppingListController.isInitialised] values
  Widget getBody() {
    // if there is no data on whether a user is signed in, or if a user is
    // in the process of signing in, display a circular progress indicator
    if (isUserSignedIn == null || isCurrentlySigningIn) {
      return const Loading();
    }

    // if a user is not signed in, let him sign in
    if (!isUserSignedIn!) {
      return Center(
        child: ElevatedButton(
          child: const Text('Zaloguj się'),
          onPressed: () async {
            setState(() => isCurrentlySigningIn = true);
            await auth.signInWithGoogle();
            setState(() => isCurrentlySigningIn = false);
          },
        ),
      );
    }

    // if shoppingListId is not specified, display an info on it
    if (!shoppingListController.isInitialised) {
      return const FullScreenInfo(
        child: const Text(
          'Nie wybrano żadnej listy zakupów. Możesz to zrobić klikając '
          'przycisk "Zmień listę" w wysuwanym menu.',
          textAlign: TextAlign.center,
        ),
      );
    }

    // if shoppingListId is specified, but the data is loading, display
    // a circular progress indicator
    if (!isFirstLoadDone) {
      return const Loading();
    }

    // for content shown if itemsToDisplay.isEmpty
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).viewPadding;
    final viewHeight = screenHeight - padding.top - kToolbarHeight;

    // otherwise, display the shopping list
    return Provider<ShoppingListController>(
      create: (context) => shoppingListController,
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
                child: const FullScreenInfo(
                  child: const Text(
                    'Brak przedmiotów do wyświetlenia',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(isUserSignedIn: auth.isUserSignedIn),
      appBar: AppBar(
        title: const Text('Lista zakupów'),
        actions: !isFirstLoadDone
            ? []
            : <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.shopping_cart_checkout,
                    color: shoppingListController.showOnlyDeclaredByUser
                        ? Colors.black
                        : Colors.deepOrange[900],
                  ),
                  onPressed: toggleBuyerFilter,
                ),
                PopupMenuButton(
                  icon: Icon(
                    Icons.filter_alt,
                    color: shoppingListController.isShopFilterApplied
                        ? Colors.black
                        : Colors.deepOrange[900],
                  ),
                  itemBuilder: (BuildContext context) =>
                      shoppingListController.filterableShops
                          .map((e) => PopupMenuItem(
                                child: Text(e),
                                value: e,
                              ))
                          .toList()
                        ..insert(
                            0,
                            const PopupMenuItem(
                              child: const Text('Wszystkie'),
                              value: '',
                            ))
                        ..insert(
                            1,
                            const PopupMenuItem(
                              child: const Text('Nieokreślone'),
                              value: '~',
                            )),
                  onSelected: setShopFilter,
                  initialValue: shoppingListController.filteredShop,
                ),
              ],
      ),
      body: getBody(),
      floatingActionButton: Visibility(
        visible: isFirstLoadDone && !isAddingProduct,
        child: FloatingActionButton(
          onPressed: addProductFunc,
          child: Icon(Icons.add_shopping_cart),
        ),
      ),
    );
  }
}
