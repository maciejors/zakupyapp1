import 'package:flutter/material.dart';

import 'package:zakupyapp/core/models/product.dart';
import 'package:zakupyapp/widgets/home/product_card_content.dart';
import 'package:zakupyapp/widgets/home/product_editor/product_editor.dart';

class ProductCard extends StatelessWidget {
  final Product? product;

  final VoidCallback editFunc;
  final VoidCallback deleteFunc;
  final VoidCallback addBuyerFunc;

  final bool isEditing;

  const ProductCard(
      {Key? key,
      required this.product,
      required this.editFunc,
      required this.deleteFunc,
      required this.addBuyerFunc,
      this.isEditing = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: product?.buyer == null
          ? Colors.orange[100]
          : product!.isDeclaredByUser
              ? Colors.orange[300]
              : Colors.orange[50],
      child: InkWell(
        onTap: isEditing ? null : deleteFunc,
        onDoubleTap: isEditing ? null : addBuyerFunc,
        onLongPress: isEditing ? null : editFunc,
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: isEditing
                ? ProductEditor(product: product)
                : ProductCardContent(product: product!)),
      ),
    );
  }
}
