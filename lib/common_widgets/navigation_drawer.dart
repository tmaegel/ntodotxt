import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/constants/app.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show Filter;
import 'package:ntodotxt/misc.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_bloc.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_state.dart';

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
  const ResponsiveNavigationDrawer({
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
      selectedIndex: _selectedIndex,
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
            context.push(context.namedLocation('todo-list'));
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

class BottomSheetNavigationDrawer extends StatelessWidget {
  final FilterListBloc bloc;

  const BottomSheetNavigationDrawer({
    required this.bloc,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.15,
      maxChildSize: 0.6,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return BlocBuilder<FilterListBloc, FilterListState>(
          bloc: bloc,
          builder: (BuildContext context, FilterListState state) {
            return ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                controller: scrollController,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListTile(
                      leading: const Icon(Icons.checklist_outlined),
                      title: const Text('Todo'),
                      onTap: () {
                        context.push(context.namedLocation('todo-list'));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListTile(
                      leading: const Icon(Icons.filter_alt_outlined),
                      title: const Text('Filter'),
                      onTap: () {
                        context.push(context.namedLocation('filter-list'));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const Divider(),
                  for (Filter filter in state.filterList)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ListTile(
                        leading: const Icon(Icons.favorite_border),
                        title: Text(filter.name),
                        onTap: () {
                          context.pushNamed('todo-list', extra: filter);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      onTap: () {
                        context.push(context.namedLocation('settings'));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
