import 'package:flutter/material.dart';

import 'package:zakupyapp/core/models/product.dart';
import 'package:zakupyapp/widgets/home/product_card/product_card_content.dart';
import 'package:zakupyapp/widgets/home/product_card/product_editor.dart';

class ProductCard extends StatelessWidget {
  final Product? product;

  // product card content
  final VoidCallback editFunc;
  final VoidCallback deleteFunc;
  final VoidCallback addBuyerFunc;

  // product editor
  final void Function(Product product) onConfirmEdit;
  final List<String> allAvailableShops;

  final bool isEditing;

  const ProductCard(
      {Key? key,
      required this.product,
      required this.editFunc,
      required this.deleteFunc,
      required this.addBuyerFunc,
      required this.onConfirmEdit,
      required this.allAvailableShops,
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
                ? ProductEditor(
                    product: product,
                    onConfirmEdit: onConfirmEdit,
                    allAvailableShops: allAvailableShops,
                  )
                : ProductCardContent(product: product!)),
      ),
    );
  }
}
