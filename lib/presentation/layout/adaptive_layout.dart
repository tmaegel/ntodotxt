import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todotxt/constants/screen.dart';
import 'package:todotxt/presentation/widgets/navigation_rail.dart';

class AdaptiveLayout extends StatelessWidget {
  // The widget to display in the body of the Scaffold.
  final Widget child;

  const AdaptiveLayout({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // final double screenWidth = MediaQuery.of(context).size.width;
    //
    // switch (screenWidth) {
    //   case < maxScreenWidthCompact:
    //     return MobileLayout(child: child);
    //   case < maxScreenWidthMedium:
    //     return TabletLayout(child: child);
    //   default:
    //     return DesktopLayout(child: child);
    // }
    return MobileLayout(child: child);
  }
}

class MobileLayout extends StatelessWidget {
  // The widget to display in the body of the Scaffold.
  final Widget child;

  const MobileLayout({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const BottomAppBar(child: null),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        context.push(context.namedLocation('todo-add'));
      },
      tooltip: 'Add todo',
      elevation: 0.0,
      focusElevation: 0.0,
      hoverElevation: 0.0,
      child: const Icon(Icons.add),
    );
  }
}

class TabletLayout extends StatelessWidget {
  // The widget to display in the body of the Scaffold.
  final Widget child;

  const TabletLayout({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const MainNavigationRail(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class DesktopLayout extends StatelessWidget {
  // The widget to display in the body of the Scaffold.
  final Widget child;

  const DesktopLayout({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const MainNavigationRail(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
