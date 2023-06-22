import 'dart:ui';

import 'package:flutter/material.dart';

class MainNavigationRail extends StatefulWidget {
  const MainNavigationRail({super.key});

  @override
  State<MainNavigationRail> createState() => _MainNavigationRailState();
}

class _MainNavigationRailState extends State<MainNavigationRail> {
  int _selectedIndex = 0;
  bool expand = false;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      destinations: _buildDestinations(),
      extended: expand,
      groupAlignment: -0.75,
      leading: const NavigatorRailFloatingActionButton(),
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  List<NavigationRailDestination> _buildDestinations() {
    return [
      const NavigationRailDestination(
        icon: Icon(Icons.home),
        label: Text('Schnellzugriff 1'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.favorite),
        label: Text('Schnellzugriff 2'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.lightbulb),
        label: Text('Schnellzugriff 3'),
      ),
    ];
  }
}

class NavigatorRailFloatingActionButton extends StatelessWidget {
  const NavigatorRailFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation =
        NavigationRail.extendedAnimation(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        // The extended fab has a shorter height than the regular fab.
        return Container(
          height: 56,
          padding: EdgeInsets.symmetric(
            vertical: lerpDouble(0, 6, animation.value)!,
          ),
          child: animation.value == 0
              ? const FloatingActionButton(
                  onPressed: null,
                  elevation: 0.0,
                  child: Icon(Icons.add),
                )
              : Align(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: animation.value,
                  child: const Padding(
                    padding: EdgeInsetsDirectional.only(start: 8),
                    child: FloatingActionButton.extended(
                      label: Text('Add todo'),
                      icon: Icon(Icons.add),
                      elevation: 0.0,
                      onPressed: null,
                    ),
                  ),
                ),
        );
      },
    );
  }
}
