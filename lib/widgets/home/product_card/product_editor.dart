import 'package:flutter/material.dart';
import 'package:zakupyapp/core/models/deadline.dart';
import 'package:zakupyapp/core/models/product.dart';
import 'package:zakupyapp/widgets/home/product_card/product_detail_editor_chip.dart';
import 'package:zakupyapp/widgets/home/product_card/select_shop_dialog.dart';

class ProductEditor extends StatefulWidget {
  // null if a new product is being added
  final Product? product;
  final List<String> allAvailableShops;

  final void Function(Product product) onConfirmEdit;
  final VoidCallback onCancelEdit;

  const ProductEditor(
      {super.key,
      this.product,
      required this.allAvailableShops,
      required this.onConfirmEdit,
      required this.onCancelEdit});

  @override
  State<ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<ProductEditor> {
  String _productName = '';
  String _selectedShop = '';
  DateTime? _selectedDay;
  Deadline? get _selectedDeadline =>
      _selectedDay == null ? null : Deadline.ignoringTime(_selectedDay!);

  final inactiveChipColor = Colors.deepOrange[300];
  final activeChipColor = Colors.deepOrange[300];

  String? productNameValidator(String? productName) {
    if (productName!.isEmpty) return 'Pole nie może być puste';
    return null;
  }

  Future<void> _selectShop() async {
    await showDialog(
        context: context,
        builder: (ctx) => SelectShopDialog(
              initialSelectedShop: _selectedShop,
              availableShops: widget.allAvailableShops,
              onConfirmSelection: (shop) =>
                  setState(() => _selectedShop = shop),
            ));
  }

  void _clearShop() {
    setState(() => _selectedShop = '');
  }

  Future<void> _selectDate() async {
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

  @override
  void initState() {
    super.initState();
    // if editing
    if (widget.product != null) {
      _productName = widget.product!.name;
      _selectedShop = widget.product!.shop ?? '';
      _selectedDay = widget.product!.deadline?.deadline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Product name input
        TextFormField(
          initialValue: _productName,
          onSaved: (value) => _productName = value!,
          decoration: InputDecoration(
            hintText: 'Nazwa produktu...',
          ),
          validator: productNameValidator,
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
      ],
    );
  }
}
