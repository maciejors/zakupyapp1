import 'package:flutter/material.dart';

import 'package:zakupyapp/services/database_manager.dart';
import 'package:zakupyapp/services/auth_manager.dart';
import 'package:zakupyapp/widgets/shared/snackbars.dart';
import 'package:zakupyapp/widgets/shared/dialogs/text_input_dialog.dart';

class CreateShoppingListAction extends StatefulWidget {
  const CreateShoppingListAction({super.key});

  @override
  State<CreateShoppingListAction> createState() =>
      _CreateShoppingListActionState();
}

class _CreateShoppingListActionState extends State<CreateShoppingListAction> {
  final _db = DatabaseManager.instance;
  final _auth = AuthManager.instance;

  Future<void> handleAddList() async {
    String? newName = await showDialog(
      context: context,
      builder: (ctx) => TextInputDialog(
        title: const Text('Nowa lista zakupów'),
        confirmButtonChild: const Text('Stwórz'),
        hintText: 'Nazwa listy',
        validator: (name) {
          if (name!.isEmpty) {
            return 'Nazwa listy jest za krótka';
          }
          if (name.length > 40) {
            return 'Nazwa listy jest za długa';
          }
          return null;
        },
      ),
    );
    // handle cancel
    if (newName == null) {
      return;
    }
    await _db.createShoppingList(newName, _auth.getUserEmail()!);
    if (mounted) {
      showSnackBar(
        context: context,
        content: const Text('Utworzono nową listę'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.add_circle,
        color: Colors.black,
      ),
      onPressed: _auth.isUserSignedIn ? handleAddList : null,
    );
  }
}
