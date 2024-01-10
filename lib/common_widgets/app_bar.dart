import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/contexts_dialog.dart';
import 'package:ntodotxt/common_widgets/filter_dialog.dart';
import 'package:ntodotxt/common_widgets/group_by_dialog.dart';
import 'package:ntodotxt/common_widgets/order_dialog.dart';
import 'package:ntodotxt/common_widgets/priorities_dialog.dart';
import 'package:ntodotxt/common_widgets/projects_dialog.dart';
import 'package:ntodotxt/constants/app.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority;
import 'package:ntodotxt/misc.dart' show CustomScrollBehavior, PlatformInfo;
import 'package:ntodotxt/presentation/drawer/widgets/drawer.dart';
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_state.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';

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
      leading: narrowView && !Navigator.of(context).canPop()
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
              PlatformInfo.isDesktopOS
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: toolbar!,
                    )
                  : toolbar!,
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
      Size.fromHeight(bottom == null ? kToolbarHeight : 89);
}

class AppBarFilterList extends StatelessWidget {
  const AppBarFilterList({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController controller = ScrollController();
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (BuildContext context, FilterState state) {
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
                  GenericActionChip(
                    avatar: const Icon(Icons.sort),
                    label: Text(state.filter.order.name),
                    onPressed: () async {
                      await FilterStateOrderDialog.dialog(
                        context: context,
                        cubit: BlocProvider.of<FilterCubit>(context),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  GenericActionChip(
                    avatar: const Icon(Icons.filter_list),
                    label: Text(state.filter.filter.name),
                    onPressed: () async {
                      await FilterStateFilterDialog.dialog(
                        context: context,
                        cubit: BlocProvider.of<FilterCubit>(context),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  GenericActionChip(
                    avatar: const Icon(Icons.workspaces_outlined),
                    label: Text(state.filter.group.name),
                    onPressed: () async {
                      await FilterStateGroupDialog.dialog(
                        context: context,
                        cubit: BlocProvider.of<FilterCubit>(context),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  GenericActionChip(
                    avatar: const Icon(Icons.flag_outlined),
                    label:
                        Text('priorities (${state.filter.priorities.length})'),
                    onPressed: () async {
                      await PriorityListDialog.dialog(
                        context: context,
                        cubit: BlocProvider.of<FilterCubit>(context),
                        items: Priority.values.toSet(),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  GenericActionChip(
                    avatar: const Icon(Icons.rocket_launch_outlined),
                    label: Text('projects (${state.filter.projects.length})'),
                    onPressed: () async {
                      await ProjectListDialog.dialog(
                        context: context,
                        cubit: BlocProvider.of<FilterCubit>(context),
                        items: context.read<TodoListBloc>().state.projects,
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  GenericActionChip(
                    avatar: const Icon(Icons.join_inner),
                    label: Text('contexts (${state.filter.contexts.length})'),
                    onPressed: () async {
                      await ContextListDialog.dialog(
                        context: context,
                        cubit: BlocProvider.of<FilterCubit>(context),
                        items: context.read<TodoListBloc>().state.contexts,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
