import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/constants/app.dart';

class DrawerDestination {
  final String label;
  final Widget icon;
  final Widget? selectedIcon;

  const DrawerDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
  });
}

const List<DrawerDestination> primaryDestinations = <DrawerDestination>[
  DrawerDestination(
    label: 'Todos',
    icon: Icon(Icons.checklist_outlined),
    selectedIcon: Icon(Icons.checklist),
  ),
  DrawerDestination(
    label: 'Filters',
    icon: Icon(Icons.filter_alt_outlined),
    selectedIcon: Icon(Icons.filter_alt),
  ),
];

const List<DrawerDestination> secondaryDestinations = <DrawerDestination>[
  DrawerDestination(
    label: 'Settings',
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings),
  ),
];

class ResponsiveNavigationDrawer extends StatefulWidget {
  final int? selectedIndex;

  const ResponsiveNavigationDrawer({
    this.selectedIndex,
    super.key,
  });

  @override
  State<ResponsiveNavigationDrawer> createState() =>
      _ResponsiveNavigationDrawerState();
}

class _ResponsiveNavigationDrawerState
    extends State<ResponsiveNavigationDrawer> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isNarrowLayout =
        MediaQuery.of(context).size.width < maxScreenWidthCompact;
    return NavigationDrawer(
      backgroundColor: !isNarrowLayout
          ? Theme.of(context).appBarTheme.backgroundColor
          : null,
      surfaceTintColor: !isNarrowLayout
          ? Theme.of(context).appBarTheme.backgroundColor
          : null,
      selectedIndex: widget.selectedIndex ?? _selectedIndex,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: SizedBox(),
        ),
        ...primaryDestinations.map(
          (DrawerDestination destination) {
            return NavigationDrawerDestination(
              label: Text(destination.label),
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Divider(),
        ),
        ...secondaryDestinations.map(
          (DrawerDestination destination) {
            return NavigationDrawerDestination(
              label: Text(destination.label),
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
            );
          },
        ),
      ],
      onDestinationSelected: (int index) {
        switch (index) {
          case 0: // Manage todos
            setState(() => _selectedIndex = index);
            context.go(context.namedLocation('todo-list'));
            break;
          case 1: // Manage filters
            setState(() => _selectedIndex = index);
            context.push(context.namedLocation('filter-list'));
            break;
          case 2: // Settings
            setState(() => _selectedIndex = index);
            context.push(context.namedLocation('settings'));
            break;
          default:
            break;
        }
        if (isNarrowLayout) {
          Navigator.pop(context); // Close drawer.
        }
      },
    );
  }
}
