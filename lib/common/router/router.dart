// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/adaptive_layout/widget/adaptive_layout.dart';
import 'package:ntodotxt/app_info/page/app_details_page.dart';
import 'package:ntodotxt/filter/model/filter_model.dart';
import 'package:ntodotxt/filter/page/filter_create_edit_page.dart';
import 'package:ntodotxt/filter/page/filter_list_page.dart';
import 'package:ntodotxt/licenses/page/licenses_page.dart';
import 'package:ntodotxt/setting/page/settings_page.dart';
import 'package:ntodotxt/todo/model/todo_model.dart';
import 'package:ntodotxt/todo/page/todo_create_edit_page.dart';
import 'package:ntodotxt/todo/page/todo_list_page.dart';
import 'package:ntodotxt/todo/page/todo_search_page.dart';
import 'package:ntodotxt/todo/state/todo_list_bloc.dart';

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
              Filter? filter = state.extra as Filter?;
              return TodoListPage(
                filter: filter,
                key: ValueKey(filter?.id ?? 'default'),
              );
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'todo/create',
                name: 'todo-create',
                builder: (BuildContext context, GoRouterState state) {
                  Todo todo = state.extra as Todo;
                  return TodoCreateEditPage(
                    initTodo: todo,
                    newTodo: true,
                    projects: context.read<TodoListBloc>().state.projects,
                    contexts: context.read<TodoListBloc>().state.contexts,
                    keyValues: context.read<TodoListBloc>().state.keyValues,
                  );
                },
              ),
              GoRoute(
                path: 'todo/edit',
                name: 'todo-edit',
                builder: (BuildContext context, GoRouterState state) {
                  Todo todo = state.extra as Todo;
                  return TodoCreateEditPage(
                    initTodo: todo,
                    newTodo: false,
                    projects: context.read<TodoListBloc>().state.projects,
                    contexts: context.read<TodoListBloc>().state.contexts,
                    keyValues: context.read<TodoListBloc>().state.keyValues,
                  );
                },
              ),
              GoRoute(
                path: 'todo/search',
                name: 'todo-search',
                builder: (BuildContext context, GoRouterState state) {
                  Filter? filter = state.extra as Filter?;
                  return TodoSearchPage(filter: filter);
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
                    initFilter: filter,
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
