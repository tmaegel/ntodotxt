import 'package:flutter/material.dart';
import 'package:ntodotxt/constants/todo.dart';

class ChipEntity {
  final String label;
  final bool selected;
  final void Function(bool)? onSelected;
  final Color? color;

  const ChipEntity({
    required this.label,
    this.selected = false,
    this.onSelected,
    this.color,
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
      selectedColor: child.color ?? defaultChipColor,
      side: const BorderSide(
        style: BorderStyle.none,
        color: Color(0xfff1f1f1),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
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
      spacing: 4.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        for (var chip in chips) GenericChip(child: chip),
      ],
    );
  }
}

class InlineChipReadOnly extends StatelessWidget {
  final String label;
  final Color? color;

  const InlineChipReadOnly({
    required this.label,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: color ?? defaultChipColor,
      ),
      child: Text(label),
    );
  }
}
