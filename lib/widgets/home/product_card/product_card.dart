import 'package:flutter/material.dart';

import 'package:zakupyapp/core/models/product.dart';
import 'package:zakupyapp/widgets/home/product_card/product_card_content.dart';
import 'package:zakupyapp/widgets/home/product_card/product_editor.dart';

class ProductCard extends StatelessWidget {
  /// null if a new product is being added
  final Product? product;

  /// not null only if a new product is being added
  final String? newProductId;

  // product card content
  final VoidCallback editFunc;
  final void Function(Product) deleteFunc;
  final VoidCallback addBuyerFunc;

  // product editor
  final void Function(Product product) onConfirmEdit;
  final void Function() onCancelEdit;

  final bool isEditing;

  const ProductCard({
    Key? key,
    required this.product,
    required this.editFunc,
    required this.deleteFunc,
    required this.addBuyerFunc,
    required this.onConfirmEdit,
    required this.onCancelEdit,
    this.isEditing = false,
    this.newProductId = null,
  }) : super(key: key);

  ProductCard.emptyEditor({
    required String newProductId,
    required void Function(Product product) onConfirmEdit,
    required void Function() onCancelEdit,
  }) : this(
          key: Key(newProductId),
          product: null,
          editFunc: () {},
          deleteFunc: (p) {},
          addBuyerFunc: () {},
          onConfirmEdit: onConfirmEdit,
          onCancelEdit: onCancelEdit,
          isEditing: true,
          newProductId: newProductId,
        );

  Color? get cardColor {
    // default or when adding a product
    if (product == null || product?.buyer == null) {
      return Colors.orange[100];
    }
    // declared by user and not editing
    if (product!.isDeclaredByUser && !isEditing) {
      return Colors.orange[300];
    }
    // declared by user but editing
    if (product!.isDeclaredByUser && isEditing) {
      return Colors.orange[200];
    }
    // declared by someone else
    return Colors.orange[50];
  }

  Future<void> showDeleteDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Usuń produkt'),
          content: Text('Czy na pewno chcesz usunąć: ${product!.name}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Anuluj'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Tak'),
              onPressed: () {
                Navigator.of(context).pop();
                deleteFunc(product!);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // otherwise cards shrink in width
      child: Card(
        color: cardColor,
        child: InkWell(
          onTap: isEditing ? null : () => showDeleteDialog(context),
          onDoubleTap: isEditing ? null : addBuyerFunc,
          onLongPress: isEditing ? null : editFunc,
          child: AnimatedSize(
            duration: Duration(milliseconds: 250),
            alignment: Alignment.topCenter,
            child: isEditing
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: ProductEditor(
                      product: product,
                      newProductId: newProductId,
                      onConfirmEdit: onConfirmEdit,
                      onCancelEdit: onCancelEdit,
                    ),
                  )
                : AnimatedSize(
                    duration: Duration(milliseconds: 250),
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ProductCardContent(product: product!),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
