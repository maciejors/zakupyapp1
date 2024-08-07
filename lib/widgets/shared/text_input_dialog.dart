import 'package:flutter/material.dart';

class TextInputDialog extends StatefulWidget {
  final String title;
  final String? initialValue;
  final String confirmText;
  final String? Function(String?)? validator;
  final String? hintText;

  const TextInputDialog({
    super.key,
    required this.title,
    this.initialValue,
    required this.confirmText,
    this.validator,
    this.hintText,
  });

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _input = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _input.text = widget.initialValue ?? '';
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _input,
          validator: widget.validator,
          decoration: InputDecoration(hintText: widget.hintText),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Anuluj'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(widget.confirmText),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_input.text);
            }
          },
        ),
      ],
    );
  }
}
