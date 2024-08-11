import 'package:flutter/material.dart';

class FullScreenInfo extends StatelessWidget {
  final Widget child;

  const FullScreenInfo({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: child,
      ),
    );
  }
}
