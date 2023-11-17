import 'package:flutter/material.dart';

class PrimaryFloatingActionButton extends StatelessWidget {
  final String tooltip;
  final Icon icon;
  final Function action;
  final String? label;

  const PrimaryFloatingActionButton({
    required this.icon,
    required this.tooltip,
    required this.action,
    this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return FloatingActionButton(
        heroTag: 'hero-$tooltip',
        elevation: 0.0,
        focusElevation: 0.0,
        hoverElevation: 0.0,
        tooltip: tooltip,
        onPressed: () => action(),
        child: icon,
      );
    } else {
      return FloatingActionButton.extended(
        heroTag: 'hero-$tooltip',
        label: Text(label!),
        elevation: 0.0,
        focusElevation: 0.0,
        hoverElevation: 0.0,
        tooltip: tooltip,
        onPressed: () => action(),
        icon: icon,
      );
    }
  }
}
