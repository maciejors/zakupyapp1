import 'package:flutter/material.dart';
import 'package:zakupyapk/utils/storage_manager.dart';
import 'package:zakupyapk/widgets/text_with_icon.dart';

class ShoppingListItem extends StatelessWidget {
  static List<String> allAvailableShops = [
    'Biedronka',
    'Lidl',
    'Selgros',
    'Emilka'
  ];

  final String id;
  final String name;
  final String shop;
  final String dateAddedToDisplay;
  final String whoAdded;
  final VoidCallback editFunc;
  final VoidCallback deleteFunc;
  final double? mainFontSize;
  // TODO: add 'product deadline'

  /// hero tag to be used if this widget is wrapped with a Hero widget
  final String heroTag;

  const ShoppingListItem(
      {Key? key,
      required this.id,
      required this.name,
      required this.shop,
      required this.dateAddedToDisplay,
      required this.whoAdded,
      required this.editFunc,
      required this.deleteFunc,
      this.mainFontSize})
      : heroTag = "shoppingListItem$id",
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!allAvailableShops.contains(shop) &&
        shop != '' &&
        shop != 'Przykładowy') {  // last one is true for settings screen
      allAvailableShops.add(shop);
    }
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
                name,
                style: TextStyle(
                  fontSize: mainFontSize * 1.2,
                ),
              ),
              SizedBox(height: mainFontSize / 3),
              Visibility(
                visible: shop != '',
                child: SimpleTextWithIcon(
                  text: 'Sklep: $shop',
                  iconData: Icons.shopping_cart,
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                  size: mainFontSize,
                ),
              ),
              SizedBox(height: mainFontSize * 0.66),
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
                      text: whoAdded,
                    ),
                  ],
                ),
              ),
              Text(
                dateAddedToDisplay,
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
