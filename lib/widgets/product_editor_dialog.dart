import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:zakupyapk/utils/database_manager.dart';
import 'package:zakupyapk/utils/date_time_functions.dart';
import 'package:zakupyapk/utils/storage_manager.dart';
import 'package:zakupyapk/widgets/labeled_checkbox.dart';
import 'package:zakupyapk/widgets/shopping_list_item.dart';
import 'package:zakupyapk/widgets/text_with_icon.dart';

class ProductEditorDialog extends StatefulWidget {
  /// Indicates the context of this dialog (editing/adding a new product)
  final bool editingProduct;

  /// Edited product. `null` if [editingProduct] is `false`
  final ShoppingListItem? shoppingListItem;

  const ProductEditorDialog(
      {Key? key, required this.editingProduct, this.shoppingListItem})
      : super(key: key);

  @override
  _ProductEditorDialogState createState() => _ProductEditorDialogState();
}

class _ProductEditorDialogState extends State<ProductEditorDialog> {
  String _productName = '';
  String _shopNameInput = '';
  String _shopSelection = '';
  bool _includeDeadline = false;
  bool _showHourInDeadline = false;
  DateTime _selectedDay = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final DatabaseManager dbManager = DatabaseManager.instance;

  String _generateProductId() {
    DateTime now = DateTime.now();
    return '${now.year}'
        '-${now.month.toString().padLeft(2, '0')}'
        '-${now.day.toString().padLeft(2, '0')}'
        '-${now.hour.toString().padLeft(2, '0')}'
        '-${now.minute.toString().padLeft(2, '0')}'
        '-${now.second.toString().padLeft(2, '0')}'
        '-${now.millisecond.toString().padLeft(3, '0')}';
  }

  void _confirmEditProduct() {
    var productData = formProductData();
    // adjusting date of creation
    productData['dateAddedToDisplay'] =
        widget.shoppingListItem!.dateAddedToDisplay;
    dbManager.storeProductFromData(
        widget.shoppingListItem!.id, productData);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Pomyślnie zedytowano produkt'),
    ));
  }

  void _addProduct() {
    dbManager.storeProductFromData(_generateProductId(), formProductData());
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Dodano produkt do listy'),
    ));
  }

  Map<String, dynamic> formProductData() {
    Map<String, dynamic> productData = {
      'name': _productName,
      'shop':
          _shopSelection == 'requestInput' ? _shopNameInput : _shopSelection,
      'dateAddedToDisplay': dateTimeToString(DateTime.now()),
      'whoAdded': SM.getUserName(),
    };
    if (_includeDeadline) {
      int hour = 0;
      int minute = 0;
      if (_showHourInDeadline) {
        hour = _selectedTime.hour;
        minute = _selectedTime.minute;
      }
      DateTime deadline = DateTime(_selectedDay.year, _selectedDay.month,
          _selectedDay.day, hour, minute);
      productData['deadline'] = deadline.toString();
      productData['showHourInDeadline'] = _showHourInDeadline;
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
      _productName = widget.shoppingListItem!.name;
      _shopSelection = widget.shoppingListItem!.shop;
      _includeDeadline = widget.shoppingListItem!.deadline != null;
      if (_includeDeadline) {
        _showHourInDeadline = widget.shoppingListItem!.showHourInDeadline!;
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
                size: SM.getMainFontSize() * 1.5,
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
              SizedBox(height: SM.getMainFontSize()),
              SimpleTextWithIcon(
                text: 'Sklep',
                iconData: Icons.shopping_cart,
                color: Colors.orange,
                size: SM.getMainFontSize() * 1.5,
                fontWeight: FontWeight.bold,
              ),

              // Shop selection
              DropdownButton(
                value: _shopSelection,
                items: ShoppingListItem.allAvailableShops
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
              SizedBox(height: SM.getMainFontSize() * 0.5),
              SimpleTextWithIcon(
                text: 'Potrzebne na',
                iconData: Icons.access_time_outlined,
                color: Colors.orange,
                size: SM.getMainFontSize() * 1.5,
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
                      _showHourInDeadline = false;
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
                    primary: Colors.black,
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
                  value: _showHourInDeadline,
                  checkboxFirst: false,
                  onChanged: (newValue) {
                    setState(() {
                      _showHourInDeadline = newValue!;
                    });
                  },
                ),
              ),

              // select time
              Visibility(
                visible: _includeDeadline && _showHourInDeadline,
                child: TextButton(
                  child: Text(timeToString(_selectedTime)),
                  style: TextButton.styleFrom(
                    primary: Colors.black,
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
