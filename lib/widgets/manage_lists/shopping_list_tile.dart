import 'package:flutter/material.dart';

import 'package:zakupyapp/core/models/shopping_list.dart';
import 'package:zakupyapp/services/auth_manager.dart';
import 'package:zakupyapp/services/database_manager.dart';
import 'package:zakupyapp/services/storage_manager.dart';
import 'package:zakupyapp/widgets/manage_lists/manage_default_shops_dialog.dart';
import 'package:zakupyapp/widgets/manage_lists/manage_users_dialog.dart';
import 'package:zakupyapp/widgets/shared/confirmation_dialog.dart';
import 'package:zakupyapp/widgets/shared/text_input_dialog.dart';

class ShoppingListTile extends StatefulWidget {
  final ShoppingList shoppingList;

  const ShoppingListTile({super.key, required this.shoppingList});

  @override
  State<ShoppingListTile> createState() => _ShoppingListTileState();
}

class _ShoppingListTileState extends State<ShoppingListTile> {
  final _db = DatabaseManager.instance;
  final _auth = AuthManager.instance;

  Future<void> handleRename() async {
    String? newName = await showDialog(
        context: context,
        builder: (ctx) => TextInputDialog(
              title: 'Zmień nazwę',
              confirmText: 'Zapisz',
              initialValue: widget.shoppingList.name,
              hintText: 'Nowa nazwa',
              validator: (name) {
                if (name!.length == 0) {
                  return 'Nazwa listy jest za krótka';
                }
                if (name.length > 40) {
                  return 'Nazwa listy jest za długa';
                }
                return null;
              },
            ));
    // handle cancel
    if (newName == null) {
      return;
    }
    await _db.renameShoppingList(widget.shoppingList.id, newName);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Zapisano nową nazwę')),
    );
  }

  Future<void> handleManageDefaultShops() async {
    List<String>? newDefaultShops = await showDialog(
      context: context,
      builder: (ctx) => ManageDefaultShopsDialog(
        initialShops: widget.shoppingList.defaultShops,
      ),
    );
    if (newDefaultShops == null) {
      return;
    }
    await _db.updateShoppingListDefaultShops(
      widget.shoppingList.id,
      newDefaultShops,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Zaaktualizowano listę domyślnych sklepów')),
    );
  }

  Future<void> handleManageUsers() async {
    await showDialog(
      context: context,
      builder: (ctx) => ManageUsersDialog(shoppingList: widget.shoppingList),
    );
  }

  Future<void> handleAddMember() async {
    String? newUserEmail = await showDialog(
        context: context,
        builder: (ctx) => TextInputDialog(
              title: 'Dodaj użytkownika do listy ${widget.shoppingList.name}',
              confirmText: 'Dodaj',
              hintText: 'Adres e-mail użytkownika',
              validator: (email) {
                if (email!.length == 0) {
                  return 'Pole nie może być puste';
                }
                return null;
              },
            ));
    // handle cancel
    if (newUserEmail == null) {
      return;
    }
    await _db.addUserToShoppingList(widget.shoppingList.id, newUserEmail);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
        'Dodano użytkownika $newUserEmail do listy ${widget.shoppingList.name}',
      )),
    );
  }

  Future<void> handleLeaveShoppingList() async {
    bool? confirmLeave = await showDialog(
        context: context,
        builder: (ctx) => ConfirmationDialog(
              title: 'Opuść listę zakupów',
              text:
                  'Czy na pewno chcesz opuścić listę zakupów ${widget.shoppingList.name}?',
            ));
    // handle cancel
    if (confirmLeave == null || confirmLeave == false) {
      return;
    }
    await _db.removeMemberFromShoppingList(
      widget.shoppingList.id,
      _auth.getUserEmail()!,
    );
    if (SM.getShoppingListId() == widget.shoppingList.id) {
      SM.setShoppingListId('');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
        'Opuszczono listę ${widget.shoppingList.name}',
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    int membersCount = widget.shoppingList.members.length;
    String usersText = membersCount == 1 ? 'użytkownik' : 'użytkowników';

    return ExpansionTile(
      title: Text(widget.shoppingList.name),
      subtitle: Text('$membersCount $usersText'),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextButton.icon(
                  onPressed: handleRename,
                  icon: const Icon(Icons.edit),
                  label: const Text('Zmień nazwę'),
                ),
                TextButton.icon(
                  onPressed: handleManageDefaultShops,
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Domyślne sklepy'),
                ),
                TextButton.icon(
                  onPressed: handleManageUsers,
                  icon: const Icon(Icons.person),
                  label: const Text('Użytkownicy'),
                ),
                TextButton.icon(
                  onPressed: handleAddMember,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Dodaj użytkownika'),
                ),
                TextButton.icon(
                  onPressed: handleLeaveShoppingList,
                  icon: const Icon(Icons.logout),
                  label: const Text('Opuść listę'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
