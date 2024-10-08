import 'package:flutter/material.dart';

class SimpleTextWithIcon extends StatelessWidget {
  final String text;
  final IconData iconData;
  final Color color;

  /// Affects the placement of an icon in the returned text.
  /// The default value is `true`.<br>
  ///
  /// `true` -> "*icon* text"<br>
  /// `false` -> "text *icon*"
  final bool iconFirst;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final double? size;

  const SimpleTextWithIcon(
      {super.key,
      required this.text,
      required this.iconData,
      required this.color,
      this.iconFirst = true,
      this.fontWeight,
      this.fontStyle,
      this.size});

  @override
  Widget build(BuildContext context) {
    double commonSize = size ?? 14;
    List<InlineSpan> children = [
      WidgetSpan(
        child: Icon(
          iconData,
          size: commonSize * 1.3,
          color: color,
        ),
      ),
      TextSpan(text: ' $text')
    ];
    if (!iconFirst) {
      children = children.reversed.toList();
    }
    return Text.rich(
      TextSpan(
        style: TextStyle(
          color: color,
          fontSize: commonSize,
          fontStyle: fontStyle,
          fontWeight: fontWeight,
        ),
        children: children,
      ),
    );
  }
}
