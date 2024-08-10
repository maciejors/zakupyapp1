import 'package:flutter/material.dart';

class DismissibleHelpDialog extends StatelessWidget {
  final Widget content;

  const DismissibleHelpDialog({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pomoc'),
      scrollable: true,
      content: content,
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
