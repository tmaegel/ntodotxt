import 'package:flutter/material.dart';
import 'package:ntodotxt/constants/app.dart';
import 'package:ntodotxt/presentation/drawer/widgets/drawer.dart';

class AdaptiveLayout extends StatelessWidget {
  final Widget child;

  const AdaptiveLayout({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < maxScreenWidthCompact) {
      return NarrowLayout(child: child);
    } else {
      return WideLayout(child: child);
    }
  }
}

class NarrowLayout extends StatelessWidget {
  final Widget child;

  const NarrowLayout({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) => child;
}

class WideLayout extends StatelessWidget {
  final Widget child;

  const WideLayout({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const NavigationRailDrawer(),
        const VerticalDivider(width: 2),
        Expanded(child: child),
      ],
    );
  }
}
