import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:zakupyapk/utils/date_to_string.dart';
import 'package:zakupyapk/utils/storage_manager.dart';
import 'package:zakupyapk/widgets/shopping_list_item.dart';
import 'package:zakupyapk/widgets/text_with_icon.dart';

class ProductEditorDialog extends StatefulWidget {
  final bool editingProduct;
  final String? productId;
  final String? initialProductName;
  final String? initialShopName;

  const ProductEditorDialog(
      {Key? key,
      required this.editingProduct,
      this.productId,
      this.initialProductName,
      this.initialShopName})
      : super(key: key);

  @override
  _ProductEditorDialogState createState() => _ProductEditorDialogState();
}

class _ProductEditorDialogState extends State<ProductEditorDialog> {
  String productName = '';
  String shopNameInput = '';
  String shopSelection = '';
  final db = FirebaseDatabase.instance.reference();

  String generateProductId() {
    DateTime now = DateTime.now();
    return '${now.year}'
        '-${now.month.toString().padLeft(2, '0')}'
        '-${now.day.toString().padLeft(2, '0')}'
        '-${now.hour.toString().padLeft(2, '0')}'
        '-${now.minute.toString().padLeft(2, '0')}'
        '-${now.second.toString().padLeft(2, '0')}'
        '-${now.millisecond.toString().padLeft(3, '0')}';
  }

  void confirmEditProduct() {
    db.child('list').child(widget.productId!).child('name').set(productName);
    db
        .child('list')
        .child(widget.productId!)
        .child('shop')
        .set(shopSelection == 'Inny:' ? shopNameInput : shopSelection);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Pomyślnie zedytowano produkt'),
    ));
  }

  void addProduct() {
    Map<String, String> productData = {
      'name': productName,
      'shop': shopSelection == 'Inny:' ? shopNameInput : shopSelection,
      'dateAddedToDisplay': dateToString(DateTime.now()),
      'whoAdded': SM.getUserName(),
    };
    db.child('list').child(generateProductId()).set(productData);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Dodano produkt do listy'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.editingProduct) {
      productName = widget.initialProductName!;
      shopSelection = widget.initialShopName!;
    }
    else {
      shopSelection = ShoppingListItem.allAvailableShops[0];
    }
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return AlertDialog(
          scrollable: true,
          title:
              Text(widget.editingProduct ? 'Edytuj produkt' : 'Dodaj produkt'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SimpleTextWithIcon(
                text: 'Nazwa produktu',
                iconData: Icons.edit,
                color: Colors.orange,
                size: SM.getMainFontSize() * 1.5,
                fontWeight: FontWeight.bold,
              ),
              TextFormField(
                focusNode: FocusNode(canRequestFocus: false),
                initialValue: productName,
                decoration: InputDecoration(
                  hintText: 'Wpisz nazwę...',
                ),
                onChanged: (input) {
                  productName = input;
                },
              ),
              SizedBox(height: SM.getMainFontSize()),
              SimpleTextWithIcon(
                text: 'Sklep',
                iconData: Icons.shopping_cart,
                color: Colors.orange,
                size: SM.getMainFontSize() * 1.5,
                fontWeight: FontWeight.bold,
              ),
              DropdownButton(
                value: shopSelection,
                items: ShoppingListItem.allAvailableShops
                    .map((e) => DropdownMenuItem(
                          child: Text(e),
                          value: e,
                        ))
                    .toList()
                      ..insert(
                          0,
                          DropdownMenuItem(
                            child: Text('Nieokreślony'),
                            value: '',
                          ))
                      ..add(DropdownMenuItem(
                        child: Text('Inny:'),
                        value: 'requestInput',
                      )),
                onChanged: (newValue) {
                  setState(() {
                    shopSelection = newValue as String;
                  });
                },
              ),
              Visibility(
                visible: shopSelection == 'requestInput',
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Nazwa sklepu',
                  ),
                  onChanged: (input) {
                    shopNameInput = input;
                  },
                ),
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
                child: Text('Anuluj'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            TextButton(
              child: Text(widget.editingProduct ? 'Zapisz' : 'Dodaj'),
              onPressed:
                  widget.editingProduct ? confirmEditProduct : addProduct,
            ),
          ],
        );
      },
    );
  }
}
