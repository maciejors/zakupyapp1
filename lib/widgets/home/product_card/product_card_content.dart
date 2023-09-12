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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Visibility(
          visible: product.buyer != null,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SimpleTextWithIcon(
              text: product.isDeclaredByUser
                  ? 'Zadeklarowałeś kupno'
                  : '${product.buyer} kupi to',
              iconData: Icons.shopping_cart_checkout,
              color: Colors.black,
              size: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          product.name,
          style: TextStyle(
              fontSize: 18
          ),
        ),
        Visibility(
          visible: product.shop != null,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SimpleTextWithIcon(
              text: 'Sklep: ${product.shop}',
              iconData: Icons.shopping_cart,
              color: Colors.black,
              fontStyle: FontStyle.italic,
              size: 15,
            ),
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
              style: TextStyle(fontSize: 14, color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: 'Dodane przez: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: product.whoAdded,
                ),
              ],
            ),
          ),
        ),
        Text(
          dateTimeToPolishString(product.dateAdded),
          style: TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
