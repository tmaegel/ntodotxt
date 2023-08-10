import 'package:flutter/material.dart';

class ChipEntity {
  final String label;
  final bool selected;
  final void Function(bool)? onSelected;

  const ChipEntity({
    required this.label,
    this.selected = false,
    this.onSelected,
  });
}

class GenericChip extends StatelessWidget {
  final ChipEntity child;

  const GenericChip({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(child.label),
      selected: child.selected,
      backgroundColor: Colors.black12,
      disabledColor: Colors.black12,
      selectedColor: Colors.lightBlue[100],
      side: const BorderSide(
        style: BorderStyle.none,
        color: Color(0xfff1f1f1),
      ),
      // @todo: Set colore for all states.
      labelStyle: const TextStyle(color: Colors.black),
      onSelected: child.onSelected != null
          ? (bool selected) => child.onSelected!(selected)
          : null,
    );
  }
}

class GenericChipGroup extends StatelessWidget {
  final List<ChipEntity> chips;

  const GenericChipGroup({
    required this.chips,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        for (var chip in chips) GenericChip(child: chip),
      ],
    );
  }
}
