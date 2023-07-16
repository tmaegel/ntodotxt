import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todotxt/login/cubit/login.dart';
import 'package:todotxt/presentation/layout/adaptive_layout.dart';
import 'package:todotxt/presentation/pages/login_page.dart';
import 'package:todotxt/presentation/pages/settings_page.dart';
import 'package:todotxt/presentation/pages/todo_add_page.dart';
import 'package:todotxt/presentation/pages/todo_view_page.dart';
import 'package:todotxt/presentation/pages/todo_edit_page.dart';
import 'package:todotxt/presentation/pages/todo_list_page.dart';
import 'package:todotxt/presentation/pages/todo_search_page.dart';
import 'package:todotxt/presentation/widgets/app_bar.dart';

class AppRouter {
  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  final LoginCubit loginCubit;

  AppRouter(this.loginCubit);

  late final GoRouter routerNarrowLayout = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (BuildContext context, GoRouterState state) {
          return const Scaffold(
            appBar: MainAppBar(title: 'Settings'),
            body: SettingsPage(),
          );
        },
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) {
          return const NarrowLayout(child: TodoListPage());
        },
        routes: [
          GoRoute(
            path: 'view/:todoIndex',
            name: 'todo-view',
            builder: (BuildContext context, GoRouterState state) {
              return NarrowLayout(
                child: TodoViewPage(
                  todoIndex: state.pathParameters['todoIndex'],
                ),
              );
            },
          ),
          GoRoute(
            path: 'edit/:todoIndex',
            name: 'todo-edit',
            builder: (BuildContext context, GoRouterState state) {
              return NarrowLayout(
                child: TodoEditPage(
                  todoIndex: state.pathParameters['todoIndex'],
                ),
              );
            },
          ),
          GoRoute(
            path: 'add',
            name: 'todo-add',
            builder: (BuildContext context, GoRouterState state) {
              return const NarrowLayout(child: TodoAddPage());
            },
          ),
          GoRoute(
            path: 'search',
            name: 'todo-search',
            builder: (BuildContext context, GoRouterState state) {
              return const NarrowLayout(child: TodoSearchPage());
            },
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final AuthStatus authState = context.read<LoginCubit>().state.status;
      final bool onLoginPage = state.fullPath == '/login';
      if (authState != AuthStatus.authenticated) {
        return onLoginPage ? null : '/login';
      }
      if (onLoginPage) {
        return '/';
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(loginCubit.stream),
  );

  late final GoRouter routerWideLayout = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return WideLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (BuildContext context, GoRouterState state) {
              return const Card(
                elevation: 0.0,
                child: Center(
                  child: Text("Placeholder"),
                ),
              );
            },
            routes: [
              GoRoute(
                path: 'view/:todoIndex',
                name: 'todo-view',
                builder: (BuildContext context, GoRouterState state) {
                  return TodoViewPage(
                    todoIndex: state.pathParameters['todoIndex'],
                  );
                },
              ),
              GoRoute(
                path: 'edit/:todoIndex',
                name: 'todo-edit',
                builder: (BuildContext context, GoRouterState state) {
                  return TodoEditPage(
                    todoIndex: state.pathParameters['todoIndex'],
                  );
                },
              ),
              GoRoute(
                path: 'add',
                name: 'todo-add',
                builder: (BuildContext context, GoRouterState state) {
                  return const TodoAddPage();
                },
              ),
              GoRoute(
                path: 'search',
                name: 'todo-search',
                builder: (BuildContext context, GoRouterState state) {
                  return const TodoSearchPage();
                },
              ),
              GoRoute(
                path: 'settings',
                name: 'settings',
                builder: (BuildContext context, GoRouterState state) {
                  return const SettingsPage();
                },
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final AuthStatus authState = context.read<LoginCubit>().state.status;
      final bool onLoginPage = state.fullPath == '/login';
      if (authState != AuthStatus.authenticated) {
        return onLoginPage ? null : '/login';
      }
      if (onLoginPage) {
        return '/';
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(loginCubit.stream),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription =
        stream.asBroadcastStream().listen((dynamic _) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
