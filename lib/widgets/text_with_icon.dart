import 'package:flutter/material.dart';

class SimpleTextWithIcon extends StatelessWidget {
  final String text;
  final IconData iconData;
  final Color color;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final double? size;

  const SimpleTextWithIcon(
      {Key? key,
      required this.text,
      required this.iconData,
      required this.color,
      this.fontWeight,
      this.fontStyle,
      this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double commonSize = size ?? Theme.of(context).textTheme.bodyText2!.fontSize ?? 14;
    return RichText(
      text: TextSpan(
          style: TextStyle(
            color: color,
            fontSize: commonSize,
            fontStyle: fontStyle,
            fontWeight: fontWeight,
          ),
          children: [
            WidgetSpan(
                child: Icon(
              iconData,
              size: commonSize * 1.3,
              color: color,
            )),
            TextSpan(text: ' $text')
          ]),
    );
  }
}
