import 'package:flutter/material.dart';

class TodoEditPage extends StatelessWidget {
  final String? todoIndex;

  const TodoEditPage({required this.todoIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Editing todo $todoIndex'),
      ),
    );
  }
}
