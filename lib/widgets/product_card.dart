import 'package:flutter/material.dart';

import 'package:zakupyapp/core/product.dart';
import 'package:zakupyapp/utils/date_time_functions.dart';
import 'package:zakupyapp/storage/storage_manager.dart';
import 'package:zakupyapp/core/urgency.dart';
import 'package:zakupyapp/widgets/text_with_icon.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  final VoidCallback editFunc;
  final VoidCallback deleteFunc;

  final double? mainFontSize;

  const ProductCard(
      {Key? key,
      required this.product,
      required this.editFunc,
      required this.deleteFunc,
      this.mainFontSize})
      : super(key: key);

  /// Forms a nice looking text with icon informing about the
  /// product's deadline.
  ///
  /// Returns an empty container if [product.deadline] is `null`.
  Widget _formDeadlineDescription(double fontSize) {
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
      size: fontSize,
      fontStyle: FontStyle.italic,
    );
  }

  @override
  Widget build(BuildContext context) {
    double mainFontSize = this.mainFontSize ?? SM.getMainFontSize();
    return Card(
      color: Colors.orange[50],
      child: InkWell(
        onTap: deleteFunc,
        onDoubleTap: editFunc,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                product.name,
                style: TextStyle(
                  fontSize: mainFontSize * 1.2,
                ),
              ),
              SizedBox(height: mainFontSize / 3),
              Visibility(
                visible: product.shop != null,
                child: SimpleTextWithIcon(
                  text: 'Sklep: ${product.shop}',
                  iconData: Icons.shopping_cart,
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                  size: mainFontSize,
                ),
              ),
              Visibility(
                visible: product.deadline != null,
                child: SizedBox(height: mainFontSize * 0.1),
              ),
              Visibility(
                visible: product.deadline != null,
                child: _formDeadlineDescription(mainFontSize),
              ),
              SizedBox(height: mainFontSize * 0.33),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: mainFontSize, color: Colors.black),
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
              Text(
                dateTimeToPolishString(product.dateAdded),
                style: TextStyle(
                  fontSize: mainFontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
