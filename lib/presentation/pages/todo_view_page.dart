import 'package:flutter/material.dart';
import 'package:todotxt/constants/screen.dart';
import 'package:todotxt/presentation/widgets/app_bar.dart';

class TodoViewPage extends StatelessWidget {
  final String? todoIndex;

  const TodoViewPage({required this.todoIndex, super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < maxScreenWidthCompact) {
      return _buildNarrowLayout(context);
    } else {
      return _buildWideLayout(context);
    }
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(showToolBar: false),
      body: Center(
        child: Text('Viewing todo $todoIndex'),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Viewing todo $todoIndex'),
      ),
    );
  }
}
