import 'package:flutter/material.dart';
import 'package:ntodotxt/constants/todo.dart';

class Subheader extends StatelessWidget {
  final String title;

  const Subheader({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ListSection extends StatelessWidget {
  final String title;

  ListSection({
    required String title,
    super.key,
  }) : title = title.toUpperCase();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: title != "" ? priorityChipColor : noPriorityColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
