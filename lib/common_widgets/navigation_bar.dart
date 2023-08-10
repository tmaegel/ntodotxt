import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/fab.dart';

class PrimaryNavigationRail extends StatelessWidget {
  const PrimaryNavigationRail({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: null,
      extended: false,
      leading: _buildCreateActionButton(context),
      groupAlignment: 1.0,
      destinations: _buildDestinations(),
      onDestinationSelected: (int index) {
        switch (index) {
          case 0: // Manage todos
            context.go(context.namedLocation('todo-list'));
            break;
          case 1: // Manage shortcuts
            // context.push(context.namedLocation('shortcut-list'));
            break;
          case 2: // Settings
            context.push(context.namedLocation('settings'));
            break;
          default:
        }
      },
    );
  }

  List<NavigationRailDestination> _buildDestinations() {
    return [
      const NavigationRailDestination(
        label: Text('Manage todos'),
        icon: Icon(Icons.rule),
      ),
      const NavigationRailDestination(
        label: Text('Manage shortcuts'),
        icon: Icon(Icons.auto_awesome),
      ),
      const NavigationRailDestination(
        label: Text('Settings'),
        icon: Icon(Icons.settings),
      ),
    ];
  }

  Widget _buildCreateActionButton(BuildContext context) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.add),
      tooltip: 'Create',
      action: () {
        context.push(context.namedLocation('todo-create'));
      },
    );
  }
}
