import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/constants/app.dart';
import 'package:ntodotxt/misc.dart' show CustomScrollBehavior;
import 'package:ntodotxt/presentation/drawer/widgets/drawer.dart';
import 'package:ntodotxt/presentation/filter/widgets/filter_chip.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? toolbar;
  final Widget? bottom;

  const MainAppBar({
    required this.title,
    this.toolbar,
    this.bottom,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool narrowView =
        MediaQuery.of(context).size.width < maxScreenWidthCompact;
    return AppBar(
      titleSpacing: narrowView ? 0.0 : null,
      title: Text(title),
      leading: narrowView && Scaffold.of(context).hasDrawer
          ? Builder(
              builder: (BuildContext context) {
                return IconButton(
                  tooltip: 'Open drawer',
                  icon: const Icon(Icons.menu),
                  onPressed: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) =>
                          const BottomSheetNavigationDrawer(),
                    );
                  },
                );
              },
            )
          : null,
      actions: toolbar == null
          ? null
          : <Widget>[
              toolbar!,
              const SizedBox(width: 8),
            ],
      bottom: bottom == null
          ? null
          : PreferredSize(
              preferredSize: Size.zero,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: bottom!,
              ),
            ),
    );
  }

  // Scaffold requires as appbar a class that implements PreferredSizeWidget.
  @override
  Size get preferredSize =>
      Size.fromHeight(bottom == null ? kToolbarHeight : 110);
}

class AppBarFilterList extends StatelessWidget {
  const AppBarFilterList({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController controller = ScrollController();

    return BlocBuilder<TodoListBloc, TodoListState>(
      builder: (BuildContext context, TodoListState todoListState) {
        return ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: SingleChildScrollView(
            controller: controller,
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FilterOrderChip(),
                  const SizedBox(width: 4),
                  const FilterFilterChip(),
                  const SizedBox(width: 4),
                  const FilterGroupChip(),
                  const SizedBox(width: 4),
                  const FilterPrioritiesChip(),
                  const SizedBox(width: 4),
                  FilterProjectsChip(availableTags: todoListState.projects),
                  const SizedBox(width: 4),
                  FilterContextsChip(availableTags: todoListState.contexts),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
