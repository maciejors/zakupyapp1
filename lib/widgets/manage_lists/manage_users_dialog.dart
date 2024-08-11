import 'package:flutter/material.dart';

import 'package:zakupyapp/core/models/shopping_list.dart';
import 'package:zakupyapp/services/auth_manager.dart';
import 'package:zakupyapp/services/database_manager.dart';
import 'package:zakupyapp/widgets/shared/snackbars.dart';
import 'package:zakupyapp/widgets/shared/dialogs/confirmation_dialog.dart';

class ManageUsersDialog extends StatefulWidget {
  final ShoppingList shoppingList;

  const ManageUsersDialog({super.key, required this.shoppingList});

  @override
  State<ManageUsersDialog> createState() => _ManageUsersDialogState();
}

class _ManageUsersDialogState extends State<ManageUsersDialog> {
  final DatabaseManager _db = DatabaseManager.instance;
  final AuthManager _auth = AuthManager.instance;

  // keeps track of actual list of users after deletions
  // because widget.shoppingList will not be updated and this is
  // more practical than using a listener
  List<String> currentUsers = [];

  Future<void> handleDeleteMember(String memberEmail) async {
    bool? confirmation = await showDialog(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        title: const Text('Uwaga'),
        content: Text('Czy na pewno chcesz usunąć użytkownika '
            '$memberEmail z listy ${widget.shoppingList.name}?'),
      ),
    );
    // handle cancel
    if (confirmation == null || !confirmation) {
      return;
    }
    // update UI
    setState(() {
      currentUsers.remove(memberEmail);
    });
    // actually remove the user
    await _db.removeMemberFromShoppingList(
      widget.shoppingList.id,
      memberEmail,
    );
    if (mounted) {
      showSnackBar(
        context: context,
        content: Text(
          'Usunięto użytkownika $memberEmail '
              'z listy ${widget.shoppingList.name}',
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    currentUsers = [...widget.shoppingList.members];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Zarządzanie użytkownikami'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Poniżej wypisane są adresy email użytkowników listy '
              '${widget.shoppingList.name}:',
            ),
          ),
          ...currentUsers.map((memberEmail) {
            return GestureDetector(
              onLongPress: _auth.getUserEmail()! == memberEmail
                  ? null
                  : () => handleDeleteMember(memberEmail),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    memberEmail,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }),
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Aby usunąć wybranego użytkownika, przytrzymaj jego nazwę.',
            ),
          ),
        ],
      ),
      scrollable: true,
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Zamknij'),
        ),
      ],
    );
  }
}
