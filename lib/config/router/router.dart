import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/app_info/pages/app_details_page.dart';
import 'package:ntodotxt/presentation/layout/adaptive_layout.dart';
import 'package:ntodotxt/presentation/licenses/pages/licenses_page.dart';
import 'package:ntodotxt/presentation/settings/pages/settings_page.dart';
import 'package:ntodotxt/presentation/todo/pages/todo_create_page.dart';
import 'package:ntodotxt/presentation/todo/pages/todo_edit_page.dart';
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
              return const TodoListPage();
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'todo/create',
                name: 'todo-create',
                builder: (BuildContext context, GoRouterState state) {
                  return TodoCreatePage(
                    availableProjectTags:
                        context.read<TodoListBloc>().state.projects,
                    availableContextTags:
                        context.read<TodoListBloc>().state.contexts,
                    availableKeyValueTags: context
                        .read<TodoListBloc>()
                        .state
                        .keyValues
                        .where((c) => !c.startsWith('due:'))
                        .toSet(),
                  );
                },
              ),
              GoRoute(
                path: 'todo/edit',
                name: 'todo-edit',
                builder: (BuildContext context, GoRouterState state) {
                  Todo todo = state.extra as Todo;
                  return TodoEditPage(
                    todo: todo,
                    availableProjectTags: context
                        .read<TodoListBloc>()
                        .state
                        .projects
                        .where((p) => !todo.projects.contains(p))
                        .toSet(),
                    availableContextTags: context
                        .read<TodoListBloc>()
                        .state
                        .contexts
                        .where((c) => !todo.contexts.contains(c))
                        .toSet(),
                    availableKeyValueTags: context
                        .read<TodoListBloc>()
                        .state
                        .keyValues
                        .where((c) =>
                            !todo.fmtKeyValues.contains(c) &&
                            !c.startsWith('due:'))
                        .toSet(),
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
