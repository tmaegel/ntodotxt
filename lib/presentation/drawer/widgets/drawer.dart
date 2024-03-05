import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show Filter;
import 'package:ntodotxt/misc.dart';
import 'package:ntodotxt/presentation/drawer/states/drawer_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_bloc.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_state.dart';

class DrawerDestination {
  final String label;
  final Widget icon;
  final Widget selectedIcon;
  final Function(BuildContext context) onTap;

  const DrawerDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.onTap,
  });
}

class NavigationRailDrawer extends StatelessWidget {
  const NavigationRailDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrawerCubit, DrawerState>(
      builder: (BuildContext context, DrawerState drawerState) {
        return BlocBuilder<FilterListBloc, FilterListState>(
          builder: (BuildContext context, FilterListState filterListState) {
            List<DrawerDestination> destinations = <DrawerDestination>[
              DrawerDestination(
                label: 'Todos',
                icon: const Icon(Icons.checklist_outlined),
                selectedIcon: const Icon(Icons.checklist),
                onTap: (BuildContext context) => context.pushNamed('todo-list'),
              ),
              DrawerDestination(
                label: 'Filters',
                icon: const Icon(Icons.filter_list_outlined),
                selectedIcon: const Icon(Icons.filter_list),
                onTap: (BuildContext context) =>
                    context.pushNamed('filter-list'),
              ),
              for (Filter filter in filterListState.filterList)
                DrawerDestination(
                  label: 'Filter: ${filter.name}',
                  icon: const Icon(Icons.star_outline),
                  selectedIcon: const Icon(Icons.star),
                  onTap: (BuildContext context) =>
                      context.pushNamed('todo-list', extra: filter),
                ),
              DrawerDestination(
                label: 'Settings',
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                onTap: (BuildContext context) => context.pushNamed('settings'),
              ),
            ];

            return NavigationRail(
              extended: true,
              selectedIndex: drawerState.index,
              groupAlignment: -1,
              onDestinationSelected: (int index) {
                final DrawerDestination d = destinations[index];
                // Navigate if location will be changed only.
                if (drawerState.index != index) {
                  context.read<DrawerCubit>().next(index);
                  d.onTap(context);
                }
              },
              labelType: NavigationRailLabelType.none,
              destinations: <NavigationRailDestination>[
                for (DrawerDestination d in destinations)
                  NavigationRailDestination(
                    label: Text(d.label),
                    icon: d.icon,
                    selectedIcon: d.selectedIcon,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class BottomSheetNavigationDrawer extends StatelessWidget {
  const BottomSheetNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.6,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return BlocBuilder<DrawerCubit, DrawerState>(
          builder: (BuildContext context, DrawerState drawerState) {
            return BlocBuilder<FilterListBloc, FilterListState>(
              builder: (BuildContext context, FilterListState filterListState) {
                List<DrawerDestination> destinations = <DrawerDestination>[
                  DrawerDestination(
                    label: 'Todos',
                    icon: const Icon(Icons.checklist_outlined),
                    selectedIcon: const Icon(Icons.checklist),
                    onTap: (BuildContext context) =>
                        context.pushNamed('todo-list'),
                  ),
                  DrawerDestination(
                    label: 'Filters',
                    icon: const Icon(Icons.filter_list_outlined),
                    selectedIcon: const Icon(Icons.filter_list),
                    onTap: (BuildContext context) =>
                        context.pushNamed('filter-list'),
                  ),
                  for (Filter filter in filterListState.filterList)
                    DrawerDestination(
                      label: 'Filter: ${filter.name}',
                      icon: const Icon(Icons.star_outline),
                      selectedIcon: const Icon(Icons.star),
                      onTap: (BuildContext context) =>
                          context.pushNamed('todo-list', extra: filter),
                    ),
                  DrawerDestination(
                    label: 'Settings',
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings),
                    onTap: (BuildContext context) =>
                        context.pushNamed('settings'),
                  ),
                ];

                return ScrollConfiguration(
                  behavior: CustomScrollBehavior(),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: destinations.length,
                    itemBuilder: (BuildContext context, int index) {
                      final DrawerDestination d = destinations[index];
                      return Column(
                        children: [
                          if (index == 0) const SizedBox(height: 14.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 2.0),
                            child: ListTile(
                              selected: drawerState.index == index,
                              leading: drawerState.index == index
                                  ? d.selectedIcon
                                  : d.icon,
                              title: Text(d.label),
                              shape: const StadiumBorder(),
                              onTap: () {
                                // Navigate if location will be changed only.
                                if (drawerState.index != index) {
                                  context.read<DrawerCubit>().next(index);
                                  d.onTap(context);
                                }
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          if (index == destinations.length - 2 || index == 1)
                            const Divider(),
                        ],
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
