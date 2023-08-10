import 'package:flutter/material.dart';

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

  Color getColor(String value) {
    switch (value) {
      case 'A':
        return Colors.redAccent.shade100;
      case 'B':
        return Colors.purpleAccent.shade100;
      case 'C':
        return Colors.orangeAccent.shade100;
      case 'D':
        return Colors.blueAccent.shade100;
      case 'E':
        return Colors.tealAccent.shade100;
      case 'F':
        return Colors.greenAccent.shade100;
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: getColor(title),
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
