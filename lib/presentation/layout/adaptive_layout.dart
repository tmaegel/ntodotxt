import 'package:flutter/material.dart';
import 'package:ntodotxt/common_widgets/navigation_drawer.dart';

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
      body: child,
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
      body: Row(
        children: [
          // To hide rounded cornors of NavigationDrawer.
          Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: const ResponsiveNavigationDrawer(),
          ),
          const VerticalDivider(width: 2),
          Expanded(child: child),
        ],
      ),
    );
  }
}
