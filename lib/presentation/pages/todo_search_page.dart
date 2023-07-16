import 'package:flutter/material.dart';
import 'package:todotxt/constants/screen.dart';
import 'package:todotxt/presentation/widgets/app_bar.dart';

class TodoSearchPage extends StatelessWidget {
  const TodoSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: screenWidth < maxScreenWidthCompact
          ? const MainAppBar(title: 'Search', showToolBar: false)
          : null,
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
