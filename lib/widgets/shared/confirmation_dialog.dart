import 'package:flutter/material.dart';

class ConfirmationDialog extends StatefulWidget {
  final Widget title;
  final Widget content;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      content: widget.content,
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
