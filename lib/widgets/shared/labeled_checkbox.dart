import 'package:flutter/material.dart';

class LabeledCheckbox extends StatefulWidget {
  // https://api.flutter.dev/flutter/material/CheckboxListTile-class.html#material.CheckboxListTile.3
  final Widget label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  /// Affects the placement of a checkbox in the returned widget.
  /// The default value is `true`.<br>
  ///
  /// `true` -> "*checkbox* label"<br>
  /// `false` -> "label *checkbox*"
  final bool checkboxFirst;

  const LabeledCheckbox({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.checkboxFirst = true,
  }) : super(key: key);

  @override
  _LabeledCheckboxState createState() => _LabeledCheckboxState();
}

class _LabeledCheckboxState extends State<LabeledCheckbox> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Checkbox(
        value: widget.value,
        onChanged: widget.onChanged,
      ),
      widget.label,
    ];
    if (!widget.checkboxFirst) {
      children = children.reversed.toList();
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          widget.onChanged(!widget.value);
        });
      },
      child: Row(
        children: children,
      ),
    );
  }
}
