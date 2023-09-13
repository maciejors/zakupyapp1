import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zakupyapp/core/models/deadline.dart';
import 'package:zakupyapp/core/models/product.dart';
import 'package:zakupyapp/core/shopping_list.dart';
import 'package:zakupyapp/storage/storage_manager.dart';
import 'package:zakupyapp/widgets/home/product_card/product_detail_editor_chip.dart';
import 'package:zakupyapp/widgets/home/product_card/select_quantity_dialog.dart';
import 'package:zakupyapp/widgets/home/product_card/select_shop_dialog.dart';

class ProductEditor extends StatefulWidget {
  // null if a new product is being added
  final Product? product;

  final void Function(Product product) onConfirmEdit;
  final VoidCallback onCancelEdit;

  const ProductEditor(
      {super.key,
      this.product,
      required this.onConfirmEdit,
      required this.onCancelEdit});

  @override
  State<ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<ProductEditor> {
  final _formKey = GlobalKey<FormState>();
  late final ShoppingList _provider;

  final _productNameFocusNode = FocusNode(canRequestFocus: false);

  String _productName = '';
  String _selectedShop = '';
  DateTime? _selectedDay;
  Deadline? get _selectedDeadline =>
      _selectedDay == null ? null : Deadline(_selectedDay!);
  double _selectedQuantity = 1;
  String _selectedQuantityUnit = 'szt.';

  String? productNameValidator(String? productName) {
    if (productName!.isEmpty) return 'Pole nie może być puste';
    return null;
  }

  Future<void> _selectQuantity() async {
    _productNameFocusNode.unfocus();
    await showDialog(
        context: context,
        builder: (ctx) => SelectQuantityDialog(
              initialSelectedQuantity: _selectedQuantity,
              initialSelectedQuantityUnit: _selectedQuantityUnit,
              availableQuantityUnits: _provider.availableQuantityUnits,
              onConfirmSelection: (quantity, quantityUnit) => setState(() {
                _selectedQuantity = quantity;
                _selectedQuantityUnit = quantityUnit;
              }),
            ));
  }

  Future<void> _selectShop() async {
    _productNameFocusNode.unfocus();
    await showDialog(
        context: context,
        builder: (ctx) => SelectShopDialog(
              initialSelectedShop: _selectedShop,
              availableShops: _provider.availableShops,
              onConfirmSelection: (shop) =>
                  setState(() => _selectedShop = shop),
            ));
  }

  void _clearShop() {
    setState(() => _selectedShop = '');
  }

  Future<void> _selectDate() async {
    _productNameFocusNode.unfocus();
    // https://stackoverflow.com/questions/52727535/what-is-the-correct-way-to-add-date-picker-in-flutter-app
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDay ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      cancelText: 'Anuluj',
      helpText: 'Wybierz datę',
    );
    if (pickedDate != null && pickedDate != _selectedDay) {
      setState(() {
        _selectedDay = pickedDate;
      });
    }
  }

  void _clearDate() {
    setState(() => _selectedDay = null);
  }

  void confirmEdit() {
    if (_formKey.currentState!.validate()) {
      final productId = widget.product == null
          ? Product.generateProductId()
          : widget.product!.id;
      final productDateAdded =
          widget.product == null ? DateTime.now() : widget.product!.dateAdded;
      final newProduct = Product(
        id: productId,
        name: _productName,
        dateAdded: productDateAdded,
        whoAdded: SM.getUsername(),
        shop: _selectedShop == '' ? null : _selectedShop,
        deadline: _selectedDeadline,
        buyer: widget.product?.buyer,
        quantity: _selectedQuantity,
        quantityUnit: _selectedQuantityUnit,
      );
      widget.onConfirmEdit(newProduct);
    }
  }

  void cancelEdit() {
    widget.onCancelEdit();
  }

  @override
  void initState() {
    super.initState();
    // get shop and quantity units lists
    _provider = Provider.of<ShoppingList>(context, listen: false);
    // if editing
    if (widget.product != null) {
      _productName = widget.product!.name;
      _selectedShop = widget.product!.shop ?? '';
      _selectedDay = widget.product!.deadline?.deadlineDay;
      _selectedQuantity = widget.product!.quantity;
      _selectedQuantityUnit = widget.product!.quantityUnit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Product name input
          TextFormField(
            initialValue: _productName,
            onChanged: (value) => _productName = value,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.only(bottom: 8),
              hintText: 'Nazwa produktu...',
            ),
            style: TextStyle(fontSize: 18),
            validator: productNameValidator,
            autofocus: true,
            focusNode: _productNameFocusNode,
          ),

          // Quantity picker
          ProductDetailEditorChip(
            active: true,
            onPress: _selectQuantity,
            activeLabel: 'Ilość: ' +
                Product.formQuantityLabel(
                  _selectedQuantity,
                  _selectedQuantityUnit,
                ),
            icon: Icon(Icons.shopping_cart),
          ),

          // Shop picker
          ProductDetailEditorChip(
            active: _selectedShop != '',
            onPress: _selectShop,
            onDisable: _clearShop,
            inactiveLabel: 'Dodaj sklep',
            activeLabel: 'Sklep: $_selectedShop',
            icon: Icon(Icons.shopping_cart),
          ),

          // Deadline picker
          ProductDetailEditorChip(
            active: _selectedDeadline != null,
            onPress: _selectDate,
            onDisable: _clearDate,
            inactiveLabel: 'Dodaj deadline',
            activeLabel:
                'Potrzebne na: ${_selectedDeadline?.getPolishDescription()}',
            icon: Icon(Icons.access_time),
          ),

          // Save/cancel buttons
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: cancelEdit,
                child: Text('Anuluj'),
                style: TextButton.styleFrom(foregroundColor: Colors.black),
              ),
              TextButton(
                onPressed: confirmEdit,
                child: Text('Zapisz'),
                style: TextButton.styleFrom(foregroundColor: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
