import 'package:flutter/material.dart';

import 'package:todotxt/presentation/widgets/app_bar.dart';
import 'package:todotxt/presentation/widgets/navigation_rail.dart';

class AdaptiveLayoutBuild extends StatelessWidget {
  const AdaptiveLayoutBuild({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        switch (constraints.maxWidth) {
          case <= 500:
            return const MobileLayout();
          case <= 1100:
            return const TabletLayout();
          default:
            return const DesktopLayout();
        }
      },
    );
  }
}

class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      body: Column(children: [
        Expanded(
          child: Container(
              color: Colors.blue,
              margin: const EdgeInsets.all(10),
              child: const Center(child: Text("test"))),
        ),
        Expanded(
          child: Container(
              color: Colors.blue,
              margin: const EdgeInsets.all(10),
              child: const Center(child: Text("test"))),
        ),
        Expanded(
          child: Container(
              color: Colors.blue,
              margin: const EdgeInsets.all(10),
              child: const Center(child: Text("test"))),
        ),
      ]),
      bottomNavigationBar: _buildBottomAppBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }

  Widget _buildFloatingActionButton() {
    return const FloatingActionButton(
      onPressed: null,
      tooltip: 'Add todo',
      elevation: 0.0,
      child: Icon(Icons.add),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Favorite',
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class TabletLayout extends StatelessWidget {
  const TabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      body: Row(
        children: [
          const MainNavigationRail(),
          Expanded(
              child: Row(children: [
            Expanded(
              child: Container(
                  color: Colors.blue,
                  margin: const EdgeInsets.all(10),
                  child: const Center(child: Text("test"))),
            ),
            Expanded(
              child: Container(
                  color: Colors.blue,
                  margin: const EdgeInsets.all(10),
                  child: const Center(child: Text("test"))),
            ),
            Expanded(
              child: Container(
                  color: Colors.blue,
                  margin: const EdgeInsets.all(10),
                  child: const Center(child: Text("test"))),
            ),
          ])),
        ],
      ),
    );
  }
}

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      body: Row(
        children: [
          const MainNavigationRail(),
          Expanded(
              child: Row(children: [
            Expanded(
              child: Container(
                  color: Colors.blue,
                  margin: const EdgeInsets.all(10),
                  child: const Center(child: Text("test"))),
            ),
            Expanded(
              child: Container(
                  color: Colors.blue,
                  margin: const EdgeInsets.all(10),
                  child: const Center(child: Text("test"))),
            ),
            Expanded(
              child: Container(
                  color: Colors.blue,
                  margin: const EdgeInsets.all(10),
                  child: const Center(child: Text("test"))),
            ),
          ])),
        ],
      ),
    );
  }
}
