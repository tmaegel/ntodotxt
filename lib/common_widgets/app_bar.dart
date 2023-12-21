import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/common_widgets/contexts_dialog.dart';
import 'package:ntodotxt/common_widgets/filter_dialog.dart';
import 'package:ntodotxt/common_widgets/group_by_dialog.dart';
import 'package:ntodotxt/common_widgets/order_dialog.dart';
import 'package:ntodotxt/common_widgets/projects_dialog.dart';
import 'package:ntodotxt/constants/app.dart' show maxScreenWidthCompact;
import 'package:ntodotxt/misc.dart' show CustomScrollBehavior, PlatformInfo;
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
    final screenWidth = MediaQuery.of(context).size.width;
    return AppBar(
      titleSpacing: screenWidth < maxScreenWidthCompact ? 0.0 : null,
      title: Text(title),
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
      Size.fromHeight(bottom == null ? kToolbarHeight : 95);
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
                  ActionChip(
                    padding: EdgeInsets.zero,
                    avatar: const Icon(Icons.sort),
                    labelPadding: const EdgeInsets.only(right: 8.0),
                    label: Text(state.filter.order.name),
                    onPressed: () async {
                      await FilterStateOrderDialog.dialog(
                        context: context,
                        cubit: BlocProvider.of<FilterCubit>(context),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  ActionChip(
                    padding: EdgeInsets.zero,
                    avatar: const Icon(Icons.filter_list),
                    labelPadding: const EdgeInsets.only(right: 8.0),
                    label: Text(state.filter.filter.name),
                    onPressed: () async {
                      await FilterStateFilterDialog.dialog(
                        context: context,
                        cubit: BlocProvider.of<FilterCubit>(context),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  ActionChip(
                    padding: EdgeInsets.zero,
                    avatar: const Icon(Icons.workspaces_outlined),
                    labelPadding: const EdgeInsets.only(right: 8.0),
                    label: Text(state.filter.group.name),
                    onPressed: () async {
                      await FilterStateGroupDialog.dialog(
                        context: context,
                        cubit: BlocProvider.of<FilterCubit>(context),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  ActionChip(
                    padding: EdgeInsets.zero,
                    avatar: const Icon(Icons.rocket_launch_outlined),
                    labelPadding: const EdgeInsets.only(right: 8.0),
                    label: const Text('projects'),
                    onPressed: () async {
                      await ProjectListDialog.dialog(
                        context: context,
                        cubit: BlocProvider.of<FilterCubit>(context),
                        items: context.read<TodoListBloc>().state.projects,
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  ActionChip(
                    padding: EdgeInsets.zero,
                    avatar: const Icon(Icons.join_inner),
                    labelPadding: const EdgeInsets.only(right: 8.0),
                    label: const Text('contexts'),
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
