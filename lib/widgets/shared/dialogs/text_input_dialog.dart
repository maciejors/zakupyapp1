import 'package:flutter/material.dart';

class TextInputDialog extends StatefulWidget {
  final Widget title;
  final Widget confirmButtonChild;
  final String? initialValue;
  final String? Function(String?)? validator;
  final String? hintText;

  const TextInputDialog({
    super.key,
    required this.title,
    required this.confirmButtonChild,
    this.initialValue,
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
      title: widget.title,
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
          child: widget.confirmButtonChild,
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
