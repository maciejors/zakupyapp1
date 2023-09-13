import 'package:flutter/material.dart';

class SelectQuantityDialog extends StatefulWidget {
  final double initialSelectedQuantity;
  final String initialSelectedQuantityUnit;
  final List<String> availableQuantityUnits;
  final void Function(double, String) onConfirmSelection;

  const SelectQuantityDialog({
    super.key,
    required this.initialSelectedQuantity,
    required this.initialSelectedQuantityUnit,
    required this.availableQuantityUnits,
    required this.onConfirmSelection,
  });

  @override
  State<SelectQuantityDialog> createState() => _SelectQuantityDialogState();
}

class _SelectQuantityDialogState extends State<SelectQuantityDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityInputFocusNode = FocusNode();

  int? _selectedChip = -1;
  List<String> get _chipLabels => [...widget.availableQuantityUnits, 'Inna:'];
  List<String> get _chipValues => [...widget.availableQuantityUnits, '~'];

  double _quantityInput = 1;
  String _selectedUnit = '';
  String _customUnitInput = '';

  String? quantityUnitValidator(String? customUnit) {
    if (_selectedUnit != '~') return null;
    if (customUnit!.isEmpty) return 'Pole nie może być puste';
    if (customUnit == '~') return 'Niedozwolona nazwa';
    return null;
  }

  List<Widget> getChips() => List<Widget>.generate(
        _chipValues.length,
        (index) => ChoiceChip(
          label: Text(_chipLabels[index]),
          selected: _selectedChip == index,
          onSelected: (bool selected) => setState(() {
            _selectedChip = index;
            _selectedUnit = _chipValues[index];
            _quantityInputFocusNode.unfocus();
          }),
          selectedColor: Colors.deepOrange[300],
        ),
      ).toList();

  void onConfirm() {
    if (_formKey.currentState!.validate()) {
      final selectedUnit =
          _selectedUnit == '~' ? _customUnitInput : _selectedUnit;
      widget.onConfirmSelection(_quantityInput, selectedUnit);
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _quantityInput = widget.initialSelectedQuantity;
    final initQuantityUnit = widget.initialSelectedQuantityUnit;
    if (widget.availableQuantityUnits.contains(initQuantityUnit)) {
      _selectedChip = _chipValues.indexOf(initQuantityUnit);
      _selectedUnit = initQuantityUnit;
    } else {
      _selectedChip = _chipValues.length - 1;
      _selectedUnit = '~';
      _customUnitInput = initQuantityUnit;
    }
  }

  @override
  void dispose() {
    _quantityInputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String initialQuantityInpValue;
    if (_quantityInput.toInt() == _quantityInput) {
      initialQuantityInpValue = _quantityInput.toInt().toString();
    } else {
      initialQuantityInpValue = _quantityInput.toString();
    }

    return AlertDialog(
      scrollable: true,
      title: Text('Podaj ilość'),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quantity input
            TextFormField(
              autofocus: true,
              focusNode: _quantityInputFocusNode,
              decoration: InputDecoration(
                hintText: 'Podaj ilość',
              ),
              keyboardType: TextInputType.number,
              initialValue: initialQuantityInpValue,
              onChanged: (value) {
                _quantityInput = double.parse(value);
              },
            ),

            // Unit selection
            Wrap(
              spacing: 5.0,
              children: getChips(),
            ),

            // Custom quantity unit input
            Visibility(
              visible: _selectedUnit == '~',
              child: TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Podaj jednostkę',
                ),
                onChanged: (value) {
                  _customUnitInput = value;
                },
                validator: quantityUnitValidator,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
            child: Text('Anuluj'),
            onPressed: () => Navigator.of(context).pop()),
        TextButton(
          child: Text('OK'),
          onPressed: onConfirm,
        ),
      ],
    );
  }
}
