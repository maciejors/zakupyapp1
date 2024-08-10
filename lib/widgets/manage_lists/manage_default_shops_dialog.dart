import 'package:flutter/material.dart';

class ManageDefaultShopsDialog extends StatefulWidget {
  final List<String> initialShops;

  const ManageDefaultShopsDialog({super.key, required this.initialShops});

  @override
  State<ManageDefaultShopsDialog> createState() =>
      _ManageDefaultShopsDialogState();
}

class _ManageDefaultShopsDialogState extends State<ManageDefaultShopsDialog> {
  List<String> provisionalShops = [];

  final _newShopFormKey = GlobalKey<FormState>();
  final _newShopInput = TextEditingController();

  void onShopDeleted(int shopIdx) {
    setState(() => provisionalShops.removeAt(shopIdx));
  }

  void onShopAdded() {
    if (_newShopFormKey.currentState!.validate()) {
      setState(() {
        provisionalShops.add(_newShopInput.text);
        _newShopInput.text = '';
      });
    }
  }

  String? newShopValidator(String? newShopName) {
    if (newShopName == null || newShopName == '') {
      return 'Nazwa sklepu jest pusta';
    }
    if (newShopName.length > 40) {
      return 'Nazwa sklepu jest za długa';
    }
    if (provisionalShops.contains(newShopName)) {
      return 'Ten sklep jest już dodany';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    provisionalShops = [...widget.initialShops];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Domyślne sklepy'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Te sklepy będą zawsze wyświetlać się do wyboru przy '
              'dodawaniu produktów. Obecna lista domyślnych sklepów:'),
          Wrap(
            spacing: 8.0,
            children: provisionalShops.asMap().entries.map((entry) {
              int idx = entry.key;
              String shop = entry.value;
              return InputChip(
                label: Text(shop),
                onDeleted: () => onShopDeleted(idx),
                materialTapTargetSize: MaterialTapTargetSize.padded,
              );
            }).toList(),
          ),
          Form(
            key: _newShopFormKey,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _newShopInput,
                    decoration: const InputDecoration(hintText: 'Nowy sklep'),
                    validator: newShopValidator,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: onShopAdded,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          )
        ],
      ),
      scrollable: true,
      actions: <Widget>[
        TextButton(
          child: const Text('Anuluj'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Zapisz'),
          onPressed: () => Navigator.of(context).pop(provisionalShops),
        ),
      ],
    );
  }
}
