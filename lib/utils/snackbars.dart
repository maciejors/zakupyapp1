import 'package:flutter/material.dart';

void showSnackBar({
  required BuildContext context,
  required Widget content,
  Duration? duration,
}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: content,
    duration: duration ?? Duration(seconds: 4),
  ));
}
