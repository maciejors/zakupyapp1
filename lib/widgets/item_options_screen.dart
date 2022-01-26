import 'package:flutter/material.dart';
import 'package:zakupyapk/widgets/shopping_list_item.dart';
import 'package:zakupyapk/widgets/text_with_icon.dart';

class ItemOptionsScreen extends StatelessWidget {
  final ShoppingListItem shoppingListItem;
  
  const ItemOptionsScreen({Key? key, required this.shoppingListItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Opcje produktu"),
      ),
      body: ListView(
        children: <Widget>[
          Hero(
            tag: shoppingListItem.heroTag,
            child: shoppingListItem,
          ),
          Visibility(
            visible: true,
            child: TextButton(
                onPressed: shoppingListItem.editFunc,
                child: SimpleTextWithIcon(
                  text: "Edytuj",
                  iconData: Icons.edit,
                  color: Colors.black,
                )),
          ),
          TextButton(
              onPressed: shoppingListItem.deleteFunc,
              child: SimpleTextWithIcon(
                text: "Usuń",
                iconData: Icons.delete,
                color: Colors.red,
              )),
        ],
      ),
    );
  }
}
