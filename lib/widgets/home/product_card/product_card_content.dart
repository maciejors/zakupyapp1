import 'package:flutter/material.dart';

import 'package:zakupyapp/widgets/shared/text_with_icon.dart';
import 'package:zakupyapp/core/models/product.dart';
import 'package:zakupyapp/core/models/deadline.dart';
import 'package:zakupyapp/utils/date_time_functions.dart';

class ProductCardContent extends StatelessWidget {
  final Product product;

  const ProductCardContent({super.key, required this.product});

  /// Forms a nice looking text with icon informing about the
  /// product's deadline.
  ///
  /// Returns an empty container if [product.deadline] is `null`.
  Widget _formDeadlineDescription() {
    if (product.deadline == null) {
      return Container();
    }
    // setting the color
    // red if date is close (today or tomorrow)
    // grey if it's too late
    // otherwise black
    Color color;
    Urgency urgency = product.deadline!.getUrgency();
    switch (urgency) {
      case Urgency.too_late:
        color = Colors.grey;
        break;
      case Urgency.urgent:
        color = Colors.red;
        break;
      case Urgency.not_urgent:
        color = Colors.black;
        break;
    }
    return SimpleTextWithIcon(
      text: 'Potrzebne na: ${product.deadline!.getPolishDescription()}',
      iconData: Icons.access_time,
      color: color,
      fontStyle: FontStyle.italic,
      size: 15,
    );
  }

  String get _authorLeadingText =>
      '${product.dateLastEdited == null ? 'Dodane' : 'Edytowane'} przez: ';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 150),
          child: product.buyer != null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: SimpleTextWithIcon(
                    text: product.isDeclaredByUser
                        ? 'Kupisz to'
                        : '${product.buyer} kupi to',
                    iconData: Icons.shopping_cart_checkout,
                    color: Colors.black,
                    size: 19,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : SizedBox.shrink(),
        ),
        Text(
          product.name,
          style: TextStyle(fontSize: 19),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Visibility(
            visible: product.quantityLabel != null,
            child: SimpleTextWithIcon(
              text: 'Ilość: ${product.quantityLabel}',
              iconData: Icons.numbers,
              color: Colors.black,
              fontStyle: FontStyle.italic,
              size: 15,
            ),
          ),
        ),
        Visibility(
          visible: product.shop != null,
          child: SimpleTextWithIcon(
            text: 'Sklep: ${product.shop}',
            iconData: Icons.shopping_cart,
            color: Colors.black,
            fontStyle: FontStyle.italic,
            size: 15,
          ),
        ),
        Visibility(
          visible: product.deadline != null,
          child: _formDeadlineDescription(),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: _authorLeadingText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: product.whoLastEdited ?? product.whoAdded,
                ),
              ],
            ),
          ),
        ),
        Text(
          dateTimeToPolishString(product.dateLastEdited ?? product.dateAdded),
          style: TextStyle(
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
