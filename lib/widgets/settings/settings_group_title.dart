import 'package:flutter/material.dart';

class SettingsGroupTitle extends StatelessWidget {
  final String titleText;

  const SettingsGroupTitle({super.key, required this.titleText});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(titleText),
      titleTextStyle: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
      leading: const SizedBox(width: 0, height: 0),
      dense: true,
      contentPadding: EdgeInsets.fromLTRB(16, 4, 16, 0),
      onTap: null,
    );
  }
}
