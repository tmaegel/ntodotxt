import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todotxt/presentation/widgets/app_bar.dart';

class TodoAddPage extends StatelessWidget {
  const TodoAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: 'Todo Add', showToolBar: false),
      body: const Center(
        child: Text('Todo Add'),
      ),
      bottomNavigationBar: BottomAppBar(child: _buildToolBar()),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      tooltip: 'Save',
      elevation: 0.0,
      focusElevation: 0.0,
      hoverElevation: 0.0,
      onPressed: () {
        context.go(context.namedLocation('home'));
      },
      child: const Icon(Icons.check),
    );
  }

  Widget _buildToolBar() {
    return Row(children: <Widget>[
      IconButton(
        tooltip: 'Due date',
        icon: const Icon(Icons.alarm),
        onPressed: () {},
      ),
      IconButton(
        tooltip: 'Project',
        icon: const Icon(Icons.label_outline),
        onPressed: () {},
      ),
      IconButton(
        tooltip: 'Context',
        icon: const Icon(Icons.outlined_flag),
        onPressed: () {},
      ),
    ]);
  }
}
