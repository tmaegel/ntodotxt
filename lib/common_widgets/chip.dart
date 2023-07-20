import 'package:flutter/material.dart';

class ActionChoiceChip extends StatefulWidget {
  final String label;

  const ActionChoiceChip({required this.label, super.key});

  @override
  State<ActionChoiceChip> createState() => _ActionChoiceChipState();
}

class _ActionChoiceChipState extends State<ActionChoiceChip> {
  bool status = false;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(widget.label),
      selected: status,
      backgroundColor: const Color(0xfff1f1f1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      side: const BorderSide(
        style: BorderStyle.none,
        color: Color(0xfff1f1f1),
      ),
      onSelected: (bool selected) {
        setState(
          () {
            status = selected;
          },
        );
      },
    );
  }
}
