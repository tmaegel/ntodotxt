import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/constants/screen.dart';

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
    label: 'Views',
    icon: Icon(Icons.favorite_outline),
    selectedIcon: Icon(Icons.favorite),
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
  const ResponsiveNavigationDrawer({super.key});

  @override
  State<ResponsiveNavigationDrawer> createState() =>
      _ResponsiveNavigationDrawerState();
}

class _ResponsiveNavigationDrawerState
    extends State<ResponsiveNavigationDrawer> {
  int selectedIndex = 0;

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
      selectedIndex: selectedIndex, // First destination is selected.
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
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
          padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
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
            _setState(index);
            context.go(context.namedLocation('todo-list'));
            break;
          case 1: // Manage shortcuts
            _setState(index);
            // context.push(context.namedLocation('shortcut-list'));
            break;
          case 2: // Settings
            _setState(index);
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

  void _setState(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}
