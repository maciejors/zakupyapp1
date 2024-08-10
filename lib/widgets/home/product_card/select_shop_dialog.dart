import 'package:flutter/material.dart';

class SelectShopDialog extends StatefulWidget {
  final String initialSelectedShop;
  final List<String> availableShops;
  final void Function(String) onConfirmSelection;

  const SelectShopDialog(
      {super.key,
      required this.initialSelectedShop,
      required this.availableShops,
      required this.onConfirmSelection});

  @override
  State<SelectShopDialog> createState() => _SelectShopDialogState();
}

class _SelectShopDialogState extends State<SelectShopDialog> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedChip = -1;
  List<String> get _chipLabels => [...widget.availableShops, 'Inny:'];
  List<String> get _chipValues => [...widget.availableShops, '~'];

  String _selectedShop = '';
  String _customShopInput = '';

  String? shopNameValidator(String? customShopName) {
    if (_selectedShop != '~') return null;
    if (customShopName!.isEmpty) return 'Pole nie może być puste';
    if (customShopName == '~') return 'Niedozwolona nazwa';
    return null;
  }

  List<Widget> getChips() => List<Widget>.generate(
        _chipValues.length,
        (index) => ChoiceChip(
          label: Text(_chipLabels[index]),
          selected: _selectedChip == index,
          onSelected: (bool selected) => setState(() {
            _selectedChip = index;
            _selectedShop = _chipValues[index];
            // close dialog early
            if (_selectedShop != '~') {
              onConfirm();
            }
          }),
          selectedColor: Colors.deepOrange[300],
        ),
      ).toList();

  void onConfirm() {
    if (_formKey.currentState!.validate()) {
      final selectedShop =
          _selectedShop == '~' ? _customShopInput : _selectedShop;
      widget.onConfirmSelection(selectedShop.trim());
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    final initShop = widget.initialSelectedShop;
    if (initShop == '') return;
    if (widget.availableShops.contains(initShop)) {
      _selectedChip = _chipValues.indexOf(initShop);
      _selectedShop = initShop;
    } else {
      _selectedChip = _chipValues.length - 1;
      _selectedShop = '~';
      _customShopInput = initShop;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Wybierz sklep'),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop selection
            Wrap(
              spacing: 5.0,
              children: getChips(),
            ),

            // Shop name input
            Visibility(
              visible: _selectedShop == '~',
              child: TextFormField(
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Nazwa sklepu'),
                onChanged: (value) => _customShopInput = value,
                validator: shopNameValidator,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
            child: const Text('Anuluj'),
            onPressed: () => Navigator.of(context).pop()),
        TextButton(
          child: const Text('OK'),
          onPressed: onConfirm,
        ),
      ],
    );
  }
}
