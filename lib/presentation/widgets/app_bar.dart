import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todotxt/constants/screen.dart';
import 'package:todotxt/todo/cubit/todo.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showToolBar;

  const MainAppBar({
    this.title,
    required this.showToolBar,
    super.key,
  });

  // Scaffold requires as appbar a class that implements PreferredSizeWidget.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (context, state) {
        return AppBar(
          leadingWidth: screenWidth >= maxScreenWidthCompact ? 80 : null,
          leading: Builder(
            builder: (BuildContext context) {
              if (context.canPop()) {
                return IconButton(
                  icon: _icon(state),
                  onPressed: () {
                    context.pop();
                    switch (state.status) {
                      case TodoStatus.editing:
                        _cancelAction(context, state);
                      case TodoStatus.creating:
                      case TodoStatus.viewing:
                      default:
                        _resetAction(context, state);
                    }
                  },
                );
              } else {
                return const IconButton(
                    icon: Icon(Icons.menu), onPressed: null);
              }
            },
          ),
          title: Text(title ?? _title(state)),
          actions: showToolBar ? const <Widget>[AppToolBar()] : null,
        );
      },
    );
  }

  /// Cancel action e.g. cancel editing process an go back to the viewing page.
  void _cancelAction(BuildContext context, TodoState state) =>
      context.read<TodoCubit>().view(index: state.index!);

  /// Reset action e.g. cancel viewing or adding process an go back to the list page.
  void _resetAction(BuildContext context, TodoState state) =>
      context.read<TodoCubit>().reset();

  Icon _icon(TodoState state) {
    switch (state.status) {
      case TodoStatus.creating:
      case TodoStatus.editing:
        return const Icon(Icons.close);
      case TodoStatus.viewing:
      default:
        return const Icon(Icons.navigate_before);
    }
  }

  String _title(TodoState state) {
    switch (state.status) {
      case TodoStatus.creating:
        return 'Add';
      case TodoStatus.editing:
        return 'Edit';
      case TodoStatus.viewing:
        return 'View';
      default:
        return 'List';
    }
  }
}

class AppToolBar extends StatelessWidget {
  const AppToolBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: 'Search',
          icon: const Icon(Icons.search),
          onPressed: () {
            context.push(context.namedLocation('todo-search'));
          },
        ),
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            context.push(context.namedLocation('settings'));
          },
        ),
      ],
    );
  }
}
