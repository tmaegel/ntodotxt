import 'package:flutter/material.dart';

class PrimaryFloatingActionButton extends StatelessWidget {
  final String tooltip;
  final Icon icon;
  final Function action;

  const PrimaryFloatingActionButton({
    required this.icon,
    required this.tooltip,
    required this.action,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'hero-$tooltip',
      mini: false,
      elevation: 0.0,
      focusElevation: 0.0,
      hoverElevation: 0.0,
      tooltip: tooltip,
      onPressed: () => action(),
      child: icon,
    );
  }
}
