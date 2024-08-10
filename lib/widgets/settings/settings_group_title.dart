import 'package:flutter/material.dart';

class SettingsGroupTitle extends StatelessWidget {
  final Widget title;

  const SettingsGroupTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      titleTextStyle: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
      leading: const SizedBox(width: 0, height: 0),
      dense: true,
      contentPadding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      onTap: null,
    );
  }
}
