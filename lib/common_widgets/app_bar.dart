import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/common_widgets/contexts_dialog.dart';
import 'package:ntodotxt/common_widgets/filter_dialog.dart';
import 'package:ntodotxt/common_widgets/group_by_dialog.dart';
import 'package:ntodotxt/common_widgets/order_dialog.dart';
import 'package:ntodotxt/common_widgets/projects_dialog.dart';
import 'package:ntodotxt/constants/app.dart' show maxScreenWidthCompact;
import 'package:ntodotxt/domain/filter/filter_model.dart';
import 'package:ntodotxt/misc.dart' show PlatformInfo;
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
      automaticallyImplyLeading: screenWidth < maxScreenWidthCompact,
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
              child: bottom!,
            ),
    );
  }

  // Scaffold requires as appbar a class that implements PreferredSizeWidget.
  @override
  Size get preferredSize =>
      Size.fromHeight(bottom == null ? kToolbarHeight : 100);
}

class PrimaryBottomAppBar extends StatelessWidget {
  final List<Widget> children;

  const PrimaryBottomAppBar({
    required this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: children,
      ),
    );
  }
}

class AppBarFilterList extends StatelessWidget {
  const AppBarFilterList({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController controller = ScrollController();
    return BlocBuilder<FilterCubit, FilterState>(
      buildWhen: (FilterState previousState, FilterState state) =>
          previousState.filter != state.filter,
      builder: (BuildContext context, FilterState state) {
        return ScrollConfiguration(
          behavior: MyCustomScrollBehavior(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18.0, 0.0, 16.0, 8.0),
            child: SingleChildScrollView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ActionChip(
                    padding: EdgeInsets.zero,
                    avatar: const Icon(Icons.sort),
                    labelPadding: const EdgeInsets.only(right: 8.0),
                    label: Text(state.filter.order.name),
                    onPressed: () async {
                      FilterCubit cubit = BlocProvider.of<FilterCubit>(context);
                      await showModalBottomSheet<ListOrder?>(
                        context: context,
                        builder: (BuildContext context) =>
                            OrderTodoListBottomSheet(cubit: cubit),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    padding: EdgeInsets.zero,
                    avatar: const Icon(Icons.filter_list),
                    labelPadding: const EdgeInsets.only(right: 8.0),
                    label: Text(state.filter.filter.name),
                    onPressed: () async {
                      FilterCubit cubit = BlocProvider.of<FilterCubit>(context);
                      await showModalBottomSheet<ListFilter?>(
                        context: context,
                        builder: (BuildContext context) =>
                            FilterTodoListBottomSheet(cubit: cubit),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    padding: EdgeInsets.zero,
                    avatar: const Icon(Icons.workspaces_outlined),
                    labelPadding: const EdgeInsets.only(right: 8.0),
                    label: Text(state.filter.group.name),
                    onPressed: () async {
                      FilterCubit cubit = BlocProvider.of<FilterCubit>(context);
                      await showModalBottomSheet<ListGroup?>(
                        context: context,
                        builder: (BuildContext context) =>
                            GroupByTodoListBottomSheet(cubit: cubit),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    padding: EdgeInsets.zero,
                    avatar: const Icon(Icons.rocket_launch_outlined),
                    labelPadding: const EdgeInsets.only(right: 8.0),
                    label: const Text('projects'),
                    onPressed: () async {
                      FilterCubit cubit = BlocProvider.of<FilterCubit>(context);
                      await showModalBottomSheet<ListGroup?>(
                        context: context,
                        builder: (BuildContext context) =>
                            ProjectListBottomSheet(
                          cubit: cubit,
                          items: context.read<TodoListBloc>().state.projects,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    padding: EdgeInsets.zero,
                    avatar: const Icon(Icons.join_inner),
                    labelPadding: const EdgeInsets.only(right: 8.0),
                    label: const Text('contexts'),
                    onPressed: () async {
                      FilterCubit cubit = BlocProvider.of<FilterCubit>(context);
                      await showModalBottomSheet<ListGroup?>(
                        context: context,
                        builder: (BuildContext context) =>
                            ContextListBottomSheet(
                          cubit: cubit,
                          items: context.read<TodoListBloc>().state.contexts,
                        ),
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

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
