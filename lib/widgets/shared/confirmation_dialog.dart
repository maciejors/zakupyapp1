import 'package:flutter/material.dart';

class ConfirmationDialog extends StatefulWidget {
  final String title;
  final String text;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.text,
  });

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Text(widget.text),
      actions: [
        TextButton(
          child: const Text('Anuluj'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Tak'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
