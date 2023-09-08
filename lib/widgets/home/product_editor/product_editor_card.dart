import 'package:flutter/material.dart';
import 'package:zakupyapp/core/models/product.dart';

class ProductEditorCard extends StatefulWidget {
  // null if a new product is being added
  final Product? product;

  const ProductEditorCard({super.key, this.product});

  @override
  State<ProductEditorCard> createState() => _ProductEditorCardState();
}

class _ProductEditorCardState extends State<ProductEditorCard> {
  String _productName = '';
  String _shopNameInput = '';
  String _shopSelection = '';

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
    return Card(
      color: Colors.orange[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _productName,
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
        ),
      ),
    );
  }
}
