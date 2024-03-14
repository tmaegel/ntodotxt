import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/constants/app.dart';
import 'package:ntodotxt/misc.dart';
import 'package:ntodotxt/presentation/drawer/widgets/drawer.dart';
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_state.dart';
import 'package:ntodotxt/presentation/login/states/login_cubit.dart';
import 'package:ntodotxt/presentation/login/states/login_state.dart';
import 'package:ntodotxt/presentation/todo_file/todo_file_cubit.dart';
import 'package:ntodotxt/presentation/todo_file/todo_file_state.dart';

class AdaptiveLayout extends StatelessWidget {
  final Widget child;

  const AdaptiveLayout({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < maxScreenWidthCompact) {
      return NotificationWrapper(
        child: NarrowLayout(child: child),
      );
    } else {
      return NotificationWrapper(
        child: WideLayout(child: child),
      );
    }
  }
}

class NotificationWrapper extends StatelessWidget {
  final Widget child;

  const NotificationWrapper({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LoginCubit, LoginState>(
          listener: (BuildContext context, LoginState state) {
            if (state is LoginError) {
              SnackBarHandler.error(context, state.message);
            }
          },
        ),
        BlocListener<TodoFileCubit, TodoFileState>(
          listener: (BuildContext context, TodoFileState state) {
            if (state is TodoFileError) {
              SnackBarHandler.error(context, state.message);
            }
          },
        ),
        BlocListener<FilterCubit, FilterState>(
          listener: (BuildContext context, FilterState state) {
            if (state is FilterError) {
              SnackBarHandler.error(context, state.message);
            }
          },
        ),
      ],
      child: child,
    );
  }
}

class NarrowLayout extends StatelessWidget {
  final Widget child;

  const NarrowLayout({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) => child;
}

class WideLayout extends StatelessWidget {
  final Widget child;

  const WideLayout({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const NavigationRailDrawer(),
        const VerticalDivider(width: 2),
        Expanded(child: child),
      ],
    );
  }
}
