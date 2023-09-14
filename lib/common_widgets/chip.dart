import 'package:flutter/material.dart';

class GenericChoiceChip extends ChoiceChip {
  const GenericChoiceChip({
    required super.label,
    super.selected = false,
    super.showCheckmark = false,
    super.onSelected,
    super.key,
  });
}

class GenericChipGroup extends StatelessWidget {
  final List<Widget> children;

  const GenericChipGroup({
    required this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: children,
    );
  }
}
