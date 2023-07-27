import 'package:flutter/material.dart';

class BasicChip extends StatelessWidget {
  final String label;
  final bool status;

  const BasicChip({required this.label, this.status = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: status ? Colors.lime : Colors.grey.shade400,
        ),
        child: Text(label),
      ),
    );
  }
}

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
