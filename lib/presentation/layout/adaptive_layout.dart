import 'package:flutter/material.dart';
import 'package:todotxt/presentation/pages/todo_list_page.dart';
import 'package:todotxt/presentation/widgets/app_bar.dart';
import 'package:todotxt/presentation/widgets/navigation_bar.dart';

class NarrowLayout extends StatelessWidget {
  // The widget to display in the body of the Scaffold.
  final Widget child;

  const NarrowLayout({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      body: child,
      bottomNavigationBar: const PrimaryBottomAppBar(),
      floatingActionButton: const PrimaryFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}

class WideLayout extends StatelessWidget {
  // The widget to display in the body of the Scaffold.
  final Widget child;

  const WideLayout({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      body: Row(
        children: [
          const PrimaryNavigationRail(),
          const Expanded(child: TodoListPage()),
          Expanded(child: child),
        ],
      ),
    );
  }
}
