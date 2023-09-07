import 'package:flutter/material.dart';

import 'package:zakupyapp/core/product.dart';
import 'package:zakupyapp/utils/date_time_functions.dart';
import 'package:zakupyapp/core/urgency.dart';
import 'package:zakupyapp/widgets/shared/text_with_icon.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  final VoidCallback editFunc;
  final VoidCallback deleteFunc;
  final VoidCallback addBuyerFunc;

  final String username;

  const ProductCard(
      {Key? key,
      required this.product,
      required this.editFunc,
      required this.deleteFunc,
      required this.addBuyerFunc,
      required this.username})
      : super(key: key);

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
    return Card(
      color: product.buyer == null
          ? Colors.orange[100]
          : product.buyer == username
              ? Colors.orange[300]
              : Colors.orange[50],
      child: InkWell(
        onTap: deleteFunc,
        onDoubleTap: addBuyerFunc,
        onLongPress: editFunc,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Visibility(
                visible: product.buyer != null,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: SimpleTextWithIcon(
                    text: product.buyer == username
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
                  padding: const EdgeInsets.only(top: 4),
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
          ),
        ),
      ),
    );
  }
}
