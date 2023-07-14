import 'package:flutter/material.dart';
import 'package:todotxt/presentation/widgets/app_bar.dart';

class TodoDetailsPage extends StatelessWidget {
  final String? todoIndex;

  const TodoDetailsPage({required this.todoIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: 'Todo Details $todoIndex', showToolBar: false),
      body: const Center(
        child: Text('Todo Details'),
      ),
    );
  }
}
