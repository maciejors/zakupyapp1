import 'package:flutter/material.dart';
import 'package:zakupyapp/core/models/product.dart';

class ProductEditor extends StatefulWidget {
  // null if a new product is being added
  final Product? product;

  const ProductEditor({super.key, this.product});

  @override
  State<ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<ProductEditor> {
  String _productName = '';
  String _shopNameInput = '';
  String _shopSelection = '';
  //TODO finish this widget

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'editing: $_productName',
          style: TextStyle(fontSize: 18),
        ),
        // Padding(
        //   padding: const EdgeInsets.only(top: 4),
        //   child: SimpleTextWithIcon(
        //     text: 'Sklep: ${product.shop}',
        //     iconData: Icons.shopping_cart,
        //     color: Colors.black,
        //     fontStyle: FontStyle.italic,
        //     size: 15,
        //   ),
        // ),
        // _formDeadlineDescription(),
      ],
    );
  }
}
