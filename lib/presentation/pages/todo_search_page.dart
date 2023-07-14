import 'package:flutter/material.dart';
import 'package:todotxt/presentation/widgets/app_bar.dart';

class TodoSearchPage extends StatelessWidget {
  const TodoSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: 'Search', showToolBar: false),
      body: const Center(
        child: Text('Searching ...'),
      ),
      bottomNavigationBar: const BottomAppBar(child: null),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }

  Widget _buildFloatingActionButton() {
    return const FloatingActionButton(
      tooltip: 'Favorite',
      elevation: 0.0,
      focusElevation: 0.0,
      hoverElevation: 0.0,
      onPressed: null,
      child: Icon(Icons.favorite_outline),
    );
  }
}
