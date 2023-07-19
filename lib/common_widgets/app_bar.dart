import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todotxt/constants/screen.dart';
import 'package:todotxt/presentation/todo/states/todo.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  const MainAppBar({this.title, super.key});

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
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.pop();
                    context.read<TodoCubit>().back();
                  },
                );
              } else {
                return const IconButton(
                    icon: Icon(Icons.menu), onPressed: null);
              }
            },
          ),
          title: Text(title ?? _title(state)),
          // title: TextField(
          //   decoration: InputDecoration(
          //     filled: true,
          //     fillColor: const Color(0xfff1f1f1),
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(32),
          //       borderSide: BorderSide.none,
          //     ),
          //     hintText: "Search",
          //     prefixIcon: const Icon(Icons.search),
          //   ),
          // ),
          actions: state is TodoInitial
              ? <Widget>[_buildPrimaryToolBar(context)]
              : null,
        );
      },
    );
  }

  Widget _buildPrimaryToolBar(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings),
          onPressed: () {
            context.push(context.namedLocation('settings'));
          },
        ),
        IconButton(
          tooltip: 'Search',
          icon: const Icon(Icons.search),
          onPressed: () {
            context.read<TodoCubit>().search();
            context.push(context.namedLocation('todo-search'));
          },
        ),
      ],
    );
  }

  String _title(TodoState state) {
    if (state is TodoViewing) {
      return 'View';
    }
    if (state is TodoCreating) {
      return 'Add';
    }
    if (state is TodoEditing) {
      return 'Edit';
    }
    if (state is TodoSearching) {
      return 'Search';
    }

    return 'List';
  }
}
