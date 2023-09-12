import 'package:flutter/material.dart';
import 'package:zakupyapp/core/models/deadline.dart';
import 'package:zakupyapp/core/models/product.dart';

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
  String _shopSelection = '';
  String _shopNameInput = '';
  DateTime? _selectedDay;
  Deadline? get _selectedDeadline =>
      _selectedDay == null ? null : Deadline.ignoringTime(_selectedDay!);

  final _formKey = GlobalKey<FormState>();

  String? validatorNotEmpty(String? value) {
    if (value!.isEmpty) return 'Pole nie może być puste';
    return null;
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
      _shopSelection = widget.product!.shop ?? '';
      _selectedDay = widget.product!.deadline?.deadline;
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
            onSaved: (value) => _productName = value!,
            decoration: InputDecoration(
              hintText: 'Nazwa produktu...',
            ),
            validator: validatorNotEmpty,
          ),

          // Shop selection
          DropdownButtonFormField(
            decoration: InputDecoration(labelText: 'Sklep'),
            value: _shopSelection,
            items: widget.allAvailableShops
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
            onChanged: (value) {
              setState(() {
                _shopSelection = value!;
              });
            },
          ),

          // Shop name input
          Visibility(
            visible: _shopSelection == 'requestInput',
            child: TextFormField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Nazwa sklepu',
              ),
              onSaved: (value) {
                _shopNameInput = value!;
              },
              validator: validatorNotEmpty,
            ),
          ),

          // Deadline picker
          _selectedDay == null
              ? ActionChip(
                  avatar: Icon(Icons.add_circle),
                  label: Text('Dodaj deadline'),
                  backgroundColor: Colors.deepOrange[200],
                  onPressed: _selectDate,
                )
              : Row(
                  // direction: Axis.horizontal,
                  children: [
                    ActionChip(
                      avatar: Icon(Icons.access_time),
                      label: Text('Potrzebne na: ' +
                          _selectedDeadline!.getPolishDescription()),
                      backgroundColor: Colors.deepOrange[300],
                      onPressed: _selectDate,
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: _clearDate,
                    ),
                  ],
                )
        ],
      ),
    );
  }
}
