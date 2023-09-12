import 'package:flutter/material.dart';

class ProductDetailEditorChip extends StatelessWidget {
  final bool active;
  final VoidCallback onPress;
  final VoidCallback onDisable;
  final String inactiveLabel;
  final String activeLabel;
  final Icon activeIcon;

  ProductDetailEditorChip(
      {super.key,
      required this.active,
      required this.onPress,
      required this.onDisable,
      required this.inactiveLabel,
      required this.activeLabel,
      required this.activeIcon});

  final inactiveChipColor = Colors.deepOrange[200];
  final activeChipColor = Colors.deepOrange[300];

  @override
  Widget build(BuildContext context) {
    return active
        ? Wrap(
            // direction: Axis.horizontal,
            children: [
              ActionChip(
                avatar: activeIcon,
                label: Text(activeLabel),
                backgroundColor: activeChipColor,
                onPressed: onPress,
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: onDisable,
              ),
            ],
          )
        : ActionChip(
            avatar: Icon(Icons.add_circle),
            label: Text(inactiveLabel),
            backgroundColor: inactiveChipColor,
            onPressed: onPress,
          );
  }
}
