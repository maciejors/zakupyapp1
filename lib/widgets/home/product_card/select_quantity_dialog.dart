import 'dart:math';

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
  final _quantityInputController = TextEditingController();

  int? _selectedChip = -1;
  List<String> get _chipLabels => [...widget.availableQuantityUnits, 'Inna:'];
  List<String> get _chipValues => [...widget.availableQuantityUnits, '~'];

  double _quantityInput = 1;

  /// 1 or -1
  int _quantityTweakSign = 1;
  String get _quantityTweakSignText => _quantityTweakSign > 0 ? '+' : '-';

  String _selectedUnit = '';
  String _customUnitInput = '';

  /// This is used as a callback to - and + buttons
  void updateQuantity(int delta) {
    final newQuantity = _quantityInput + delta;
    // eliminate rounding errors
    final tenToTenth = pow(10, 10);
    double newQuantityRounded =
        (newQuantity * tenToTenth).roundToDouble() / tenToTenth;
    if (newQuantityRounded < 0) {
      newQuantityRounded = 0.0;
    }
    setState(() => _quantityInput = newQuantityRounded);
  }

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
      widget.onConfirmSelection(_quantityInput, selectedUnit.trim());
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
    if (_quantityInput.toInt() == _quantityInput) {
      _quantityInputController.text = _quantityInput.toInt().toString();
    } else {
      _quantityInputController.text = _quantityInput.toString();
    }

    final tweakButtonStyle = OutlinedButton.styleFrom(
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: Size.fromRadius(15),
      padding: EdgeInsets.only(left: 8, right: 8),
      textStyle: TextStyle(fontFamily: 'monospace')
    );

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
              controller: _quantityInputController,
              focusNode: _quantityInputFocusNode,
              decoration: InputDecoration(
                hintText: 'Podaj ilość',
                counterText: '',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _quantityInput = double.parse(value);
              },
            ),

            // Quantity tweak
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton(
                  onPressed: () => updateQuantity(1 * _quantityTweakSign),
                  child: Text('${_quantityTweakSignText}1'),
                  style: tweakButtonStyle,
                ),
                OutlinedButton(
                  onPressed: () => updateQuantity(10 * _quantityTweakSign),
                  child: Text('${_quantityTweakSignText}10'),
                  style: tweakButtonStyle,
                ),
                OutlinedButton(
                  onPressed: () => updateQuantity(100 * _quantityTweakSign),
                  child: Text('${_quantityTweakSignText}100'),
                  style: tweakButtonStyle,
                ),
                OutlinedButton(
                  onPressed: () => setState(() {
                    _quantityTweakSign = _quantityTweakSign * -1;
                  }),
                  child: Text('+/-'),
                  style: tweakButtonStyle,
                ),
                OutlinedButton(
                  onPressed: () => setState(() {
                    _quantityInput = 0;
                  }),
                  child: Text('0'),
                  style: tweakButtonStyle,
                ),
              ],
            ),

            Divider(height: 50),

            // Unit selection
            Text(
              'Jednostka:',
              style: TextStyle(fontSize: 18),
            ),
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
