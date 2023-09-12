import 'package:flutter/material.dart';
import 'package:zakupyapp/core/models/product.dart';

class ProductEditor extends StatefulWidget {
  // null if a new product is being added
  final Product? product;
  final List<String> allAvailableShops;

  final void Function(Product product) onConfirmEdit;

  const ProductEditor(
      {super.key,
      this.product,
      required this.onConfirmEdit,
      required this.allAvailableShops});

  @override
  State<ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<ProductEditor> {
  String _productName = '';
  String _shopSelection = '';
  String _shopNameInput = '';

  final _formKey = GlobalKey<FormState>();

  String? validatorNotEmpty(String? value) {
    if (value!.isEmpty) return 'Pole nie może być puste';
    return null;
  }

  @override
  void initState() {
    super.initState();
    // if editing
    if (widget.product != null) {
      _productName = widget.product!.name;
      _shopSelection = widget.product!.shop ?? '';
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
                _shopSelection = value as String;
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
        ],
      ),
    );
  }
}
