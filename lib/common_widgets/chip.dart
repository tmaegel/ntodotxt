import 'package:flutter/material.dart';
import 'package:ntodotxt/constants/todo.dart';

abstract class GenericChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final void Function(bool)? onSelected;

  const GenericChip({
    required this.label,
    this.onSelected,
    this.selected = false,
    this.color,
    super.key,
  });
}

class GenericChoiceChip extends GenericChip {
  const GenericChoiceChip({
    required super.label,
    super.onSelected,
    super.selected,
    super.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RawChip(
      showCheckmark: false,
      label: Text(label),
      selected: selected,
      backgroundColor: colorLightGrey,
      disabledColor: colorLightGrey,
      selectedColor: color ?? defaultChipColor,
      side: const BorderSide(
        style: BorderStyle.none,
        color: colorLightGrey,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      labelStyle: const TextStyle(color: Colors.black),
      onSelected:
          onSelected != null ? (bool selected) => onSelected!(selected) : null,
    );
  }
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
