import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/domain/saved_filter/filter_model.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/app_info/pages/app_details_page.dart';
import 'package:ntodotxt/presentation/layout/adaptive_layout.dart';
import 'package:ntodotxt/presentation/licenses/pages/licenses_page.dart';
import 'package:ntodotxt/presentation/saved_filter/pages/filter_create_edit_page.dart';
import 'package:ntodotxt/presentation/saved_filter/pages/filter_list_page.dart';
import 'package:ntodotxt/presentation/settings/pages/settings_page.dart';
import 'package:ntodotxt/presentation/todo/pages/todo_create_edit_page.dart';
import 'package:ntodotxt/presentation/todo/pages/todo_list_page.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';

class AppRouter {
  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  AppRouter();

  late final GoRouter config = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/todo',
    debugLogDiagnostics: false,
    routes: <RouteBase>[
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AdaptiveLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (BuildContext context, GoRouterState state) {
              return const SettingsPage();
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'settings/app-info',
                name: 'app-info',
                builder: (BuildContext context, GoRouterState state) {
                  return const AppInfoPage();
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'settings/app-info/licenses',
                    name: 'licenses',
                    builder: (BuildContext context, GoRouterState state) {
                      return const LicenceListPage();
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/todo',
            name: 'todo-list',
            builder: (BuildContext context, GoRouterState state) {
              return TodoListPage();
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'todo/create',
                name: 'todo-create',
                builder: (BuildContext context, GoRouterState state) {
                  Set<String> projects =
                      context.read<TodoListBloc>().state.projects;
                  Set<String> contexts =
                      context.read<TodoListBloc>().state.contexts;
                  Set<String> keyValues =
                      context.read<TodoListBloc>().state.keyValues;
                  return TodoCreateEditPage(
                    availableProjectTags: projects,
                    availableContextTags: contexts,
                    availableKeyValueTags: keyValues
                        .where(
                          (c) => !c.startsWith('due:'),
                        )
                        .toSet(),
                  );
                },
              ),
              GoRoute(
                path: 'todo/edit',
                name: 'todo-edit',
                builder: (BuildContext context, GoRouterState state) {
                  Todo todo = state.extra as Todo;
                  Set<String> projects =
                      context.read<TodoListBloc>().state.projects;
                  Set<String> contexts =
                      context.read<TodoListBloc>().state.contexts;
                  Set<String> keyValues =
                      context.read<TodoListBloc>().state.keyValues;
                  return TodoCreateEditPage(
                    todo: todo,
                    availableProjectTags: projects
                        .where(
                          (p) => !todo.projects.contains(p),
                        )
                        .toSet(),
                    availableContextTags: contexts
                        .where(
                          (c) => !todo.contexts.contains(c),
                        )
                        .toSet(),
                    availableKeyValueTags: keyValues
                        .where(
                          (c) =>
                              !todo.fmtKeyValues.contains(c) &&
                              !c.startsWith('due:'),
                        )
                        .toSet(),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/filter',
            name: 'filter-list',
            builder: (BuildContext context, GoRouterState state) {
              return const FilterListPage();
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'filter/create',
                name: 'filter-create',
                builder: (BuildContext context, GoRouterState state) {
                  return FilterCreateEditPage(
                    projects: context.read<TodoListBloc>().state.projects,
                    contexts: context.read<TodoListBloc>().state.contexts,
                  );
                },
              ),
              GoRoute(
                path: 'filter/edit',
                name: 'filter-edit',
                builder: (BuildContext context, GoRouterState state) {
                  Filter filter = state.extra as Filter;
                  return FilterCreateEditPage(
                    filter: filter,
                    projects: context.read<TodoListBloc>().state.projects,
                    contexts: context.read<TodoListBloc>().state.contexts,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
