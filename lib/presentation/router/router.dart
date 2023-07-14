import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todotxt/login/login.dart';
import 'package:todotxt/presentation/layout/adaptive_layout.dart';
import 'package:todotxt/presentation/pages/login_page.dart';
import 'package:todotxt/presentation/pages/settings_page.dart';
import 'package:todotxt/presentation/pages/todo_add_page.dart';
import 'package:todotxt/presentation/pages/todo_details_page.dart';
import 'package:todotxt/presentation/pages/todo_list_page.dart';
import 'package:todotxt/presentation/pages/todo_search_page.dart';

class AppRouter {
  final LoginCubit loginCubit;

  AppRouter(this.loginCubit);

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'todo-list',
        builder: (BuildContext context, GoRouterState state) {
          return const AdaptiveLayout(child: TodoListPage());
        },
        routes: [
          GoRoute(
            path: 'details/:todoIndex',
            name: 'todo-details',
            builder: (BuildContext context, GoRouterState state) {
              return TodoDetailsPage(
                todoIndex: state.pathParameters['todoIndex'],
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        name: 'todo-search',
        builder: (BuildContext context, GoRouterState state) {
          return const TodoSearchPage();
        },
      ),
      GoRoute(
        path: '/add',
        name: 'todo-add',
        builder: (BuildContext context, GoRouterState state) {
          return const TodoAddPage();
        },
      ),
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
          return const SettingsPage();
        },
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
