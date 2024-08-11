import 'package:flutter/material.dart';
import 'package:zakupyapp/widgets/shared/dialogs/dismissible_help_dialog.dart';

/// A wrapper for SwitchListTile in settings, which makes it so that if a
/// user holds the tile, it will display a dialog with more information
/// on the setting
class SettingInfoWrapper extends StatelessWidget {
  final Widget child;
  final Widget infoContent;

  const SettingInfoWrapper(
      {super.key, required this.child, required this.infoContent});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => showDialog(
        context: context,
        builder: (ctx) => DismissibleHelpDialog(content: infoContent),
      ),
      child: child,
    );
  }
}
