import 'package:flutter/material.dart';
import 'package:ntodotxt/common_widgets/navigation_bar.dart';

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
          const PrimaryNavigationRail(),
          const VerticalDivider(
              thickness: 1, width: 1, color: Color(0xfff1f1f1)),
          Expanded(child: child),
        ],
      ),
    );
  }
}
