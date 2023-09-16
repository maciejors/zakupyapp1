import 'package:flutter/material.dart';

class ProductDetailEditorChip extends StatelessWidget {
  final bool active;
  final VoidCallback onPress;
  final VoidCallback? onDisable;
  final String inactiveLabel;
  final String activeLabel;
  final Icon icon;

  ProductDetailEditorChip(
      {super.key,
      required this.active,
      required this.onPress,
      this.onDisable,
      this.inactiveLabel = '',
      required this.activeLabel,
      required this.icon});

  final inactiveChipColor = Colors.deepOrange[200];
  final activeChipColor = Colors.deepOrange[400];

  @override
  Widget build(BuildContext context) {
    return active
        ? Wrap(
            // direction: Axis.horizontal,
            children: [
              ActionChip(
                avatar: icon,
                label: Text(
                  activeLabel,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                backgroundColor: activeChipColor,
                onPressed: onPress,
              ),
              Visibility(
                visible: onDisable != null,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: onDisable,
                ),
              ),
            ],
          )
        : ActionChip(
            avatar: icon,
            label: Text(
              inactiveLabel,
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            backgroundColor: inactiveChipColor,
            onPressed: onPress,
          );
  }
}
