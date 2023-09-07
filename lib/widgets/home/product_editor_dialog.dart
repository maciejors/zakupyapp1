import 'package:flutter/material.dart';

import 'package:zakupyapp/core/deadline.dart';
import 'package:zakupyapp/core/product.dart';
import 'package:zakupyapp/storage/database_manager.dart';
import 'package:zakupyapp/utils/date_time_functions.dart';
import 'package:zakupyapp/storage/storage_manager.dart';
import 'package:zakupyapp/widgets/shared/labeled_checkbox.dart';
import 'package:zakupyapp/widgets/shared/text_with_icon.dart';

class ProductEditorDialog extends StatefulWidget {
  /// Indicates the context of this dialog (editing/adding a new product)
  final bool editingProduct;

  /// Edited product. `null` if [editingProduct] is `false`
  final Product? product;

  const ProductEditorDialog(
      {Key? key, required this.editingProduct, this.product})
      : super(key: key);

  @override
  _ProductEditorDialogState createState() => _ProductEditorDialogState();
}

class _ProductEditorDialogState extends State<ProductEditorDialog> {
  String _productName = '';
  String _shopNameInput = '';
  String _shopSelection = '';
  bool _includeDeadline = false;
  bool _includeTimeInDeadline = false;
  DateTime _selectedDay = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final DatabaseManager dbManager = DatabaseManager.instance;

  Future<void> _confirmEditProduct() async {
    var productData = formProductDataFromInput();
    // adjusting date of creation
    productData['dateAdded'] = widget.product!.dateAdded.toString();
    await dbManager.storeProductFromData(widget.product!.id, productData);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Pomyślnie zedytowano produkt'),
    ));
  }

  Future<void> _addProduct() async {
    await dbManager.storeProductFromData(
        Product.generateProductId(), formProductDataFromInput());
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Dodano produkt do listy'),
    ));
  }

  Map<String, String> formProductDataFromInput() {
    var productData = {
      'name': _productName,
      'dateAdded': DateTime.now().toString(),
      'whoAdded': SM.getUsername(),
    };
    if (_shopSelection != '') {
      productData['shop'] =
          _shopSelection == 'requestInput' ? _shopNameInput : _shopSelection;
    }
    if (_includeDeadline) {
      Deadline deadline;
      if (_includeTimeInDeadline) {
        deadline = Deadline.fromDateAndTime(_selectedDay, _selectedTime);
      } else {
        deadline = Deadline.ignoringTime(_selectedDay);
      }
      productData['deadline'] = deadline.toString();
    }
    return productData;
  }

  Future<void> _selectDate(BuildContext context) async {
    // https://stackoverflow.com/questions/52727535/what-is-the-correct-way-to-add-date-picker-in-flutter-app
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100, 12, 31),
    );
    if (pickedDate != null && pickedDate != _selectedDay) {
      setState(() {
        _selectedDay = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.editingProduct) {
      _productName = widget.product!.name;
      _shopSelection = widget.product!.shop ?? '';
      _includeDeadline = widget.product!.deadline != null;
      if (_includeDeadline) {
        _includeTimeInDeadline = !widget.product!.deadline!.isIgnoringTime;
      }
    } else {
      _shopSelection = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return AlertDialog(
          scrollable: true,
          title:
              Text(widget.editingProduct ? 'Edytuj produkt' : 'Dodaj produkt'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Product name title
              SimpleTextWithIcon(
                text: 'Nazwa produktu',
                iconData: Icons.edit,
                color: Colors.orange,
                size: 18,
                fontWeight: FontWeight.bold,
              ),

              // Product name input
              TextFormField(
                focusNode: FocusNode(canRequestFocus: false),
                initialValue: _productName,
                decoration: InputDecoration(
                  hintText: 'Wpisz nazwę...',
                ),
                onChanged: (input) {
                  _productName = input;
                },
              ),

              // Shop selection title
              SizedBox(height: 14),
              SimpleTextWithIcon(
                text: 'Sklep',
                iconData: Icons.shopping_cart,
                color: Colors.orange,
                size: 18,
                fontWeight: FontWeight.bold,
              ),

              // Shop selection
              DropdownButton(
                value: _shopSelection,
                items: Product.allAvailableShops
                    .map((e) => DropdownMenuItem(
                          child: Text(e),
                          value: e,
                        ))
                    .toList()
                  ..insert(
                      0,
                      DropdownMenuItem(
                        child: Text('Nieokreślony'),
                        value: '',
                      ))
                  ..add(DropdownMenuItem(
                    child: Text('Inny:'),
                    value: 'requestInput',
                  )),
                onChanged: (newValue) {
                  setState(() {
                    _shopSelection = newValue as String;
                  });
                },
              ),

              // Shop name input
              Visibility(
                visible: _shopSelection == 'requestInput',
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Nazwa sklepu',
                  ),
                  onChanged: (input) {
                    _shopNameInput = input;
                  },
                ),
              ),

              // Deadline title
              SizedBox(height: 7),
              SimpleTextWithIcon(
                text: 'Potrzebne na',
                iconData: Icons.access_time_outlined,
                color: Colors.orange,
                size: 18,
                fontWeight: FontWeight.bold,
              ),

              // Include deadline?
              LabeledCheckbox(
                label: Text('Dodaj "deadline"'),
                value: _includeDeadline,
                checkboxFirst: false,
                onChanged: (newValue) {
                  setState(() {
                    _includeDeadline = newValue!;
                    if (!_includeDeadline) {
                      _includeTimeInDeadline = false;
                    }
                  });
                },
              ),

              // Select deadline
              Visibility(
                visible: _includeDeadline,
                child: TextButton(
                  child: Text(dateToString(_selectedDay)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectDate(context);
                    });
                  },
                ),
              ),

              // Include time?
              Visibility(
                visible: _includeDeadline,
                child: LabeledCheckbox(
                  label: Text('Ustal godzinę'),
                  value: _includeTimeInDeadline,
                  checkboxFirst: false,
                  onChanged: (newValue) {
                    setState(() {
                      _includeTimeInDeadline = newValue!;
                    });
                  },
                ),
              ),

              // select time
              Visibility(
                visible: _includeDeadline && _includeTimeInDeadline,
                child: TextButton(
                  child: Text(timeToString(_selectedTime)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectTime(context);
                    });
                  },
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
                child: Text('Anuluj'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            TextButton(
              child: Text(widget.editingProduct ? 'Zapisz' : 'Dodaj'),
              onPressed:
                  widget.editingProduct ? _confirmEditProduct : _addProduct,
            ),
          ],
        );
      },
    );
  }
}
