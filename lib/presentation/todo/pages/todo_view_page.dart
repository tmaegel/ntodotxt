import 'package:flutter/material.dart';

class TodoViewPage extends StatelessWidget {
  final String? todoIndex;

  const TodoViewPage({required this.todoIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Viewing todo $todoIndex'),
      ),
    );
  }
}
