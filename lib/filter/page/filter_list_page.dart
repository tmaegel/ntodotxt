import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common/misc.dart' show PopScopeDrawer, SnackBarHandler;
import 'package:ntodotxt/common/widget/app_bar.dart';
import 'package:ntodotxt/common/widget/chip.dart';
import 'package:ntodotxt/common/widget/confirm_dialog.dart';
import 'package:ntodotxt/common/widget/scroll_to_top.dart';
import 'package:ntodotxt/filter/model/filter_model.dart';
import 'package:ntodotxt/filter/state/filter_list_bloc.dart';
import 'package:ntodotxt/filter/state/filter_list_event.dart';
import 'package:ntodotxt/filter/state/filter_list_state.dart';
import 'package:ntodotxt/setting/state/interaction_settings_cubit.dart';
import 'package:ntodotxt/setting/state/interaction_settings_state.dart';
import 'package:ntodotxt/todo/model/todo_model.dart' show Priority;

class FilterListPage extends ScollToTopView {
  const FilterListPage({super.key});

  @override
  State<FilterListPage> createState() => _FilterListPageState();
}

class _FilterListPageState extends ScollToTopViewState<FilterListPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterListBloc, FilterListState>(
      builder: (BuildContext context, FilterListState state) {
        return PopScopeDrawer(
          child: Scaffold(
            body: CustomScrollView(
              controller: scrollController,
              slivers: [
                MainSliverAppBar(
                  title: 'Filters',
                  subtitle: '${state.filterList.length} filter(s)',
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return FilterListTile(filter: state.filterList[index]);
                    },
                    childCount: state.filterList.length,
                  ),
                ),
              ],
            ),
            drawer: Container(),
            floatingActionButton: scrolledDown
                ? FloatingActionButton.small(
                    tooltip: 'Go to top',
                    child: const Icon(Icons.keyboard_arrow_up),
                    onPressed: () => scrollToTop(),
                  )
                : FloatingActionButton(
                    tooltip: 'Add filter',
                    child: const Icon(Icons.add),
                    onPressed: () => context.pushNamed('filter-create'),
                  ),
          ),
        );
      },
    );
  }
}

///
/// Components
///

class FilterListTile extends StatelessWidget {
  final Filter filter;

  const FilterListTile({
    required this.filter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InteractionSettingsCubit, InteractionSettingsState>(
      buildWhen: (InteractionSettingsState previousState,
              InteractionSettingsState state) =>
          previousState.swipeRightActionEnabled !=
          state.swipeRightActionEnabled,
      builder: (BuildContext context, InteractionSettingsState state) {
        return Dismissible(
          key: ValueKey<int>(filter.id!),
          direction: state.swipeRightActionEnabled
              ? DismissDirection.startToEnd
              : DismissDirection.none,
          dismissThresholds: const {
            DismissDirection.startToEnd: 0.5,
            DismissDirection.endToStart: 0.5,
          },
          background: Container(
            color: Theme.of(context).colorScheme.error, // red
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16.0),
            child: Icon(Icons.delete),
          ),
          confirmDismiss: (DismissDirection direction) async {
            // Delete
            if (direction == DismissDirection.startToEnd) {
              return await ConfirmationDialog.dialog(
                context: context,
                title: 'Delete filter',
                message: 'Do you want to delete the filter?',
                actionLabel: 'Delete',
                cancelLabel: 'Cancel',
              );
            }
            return true;
          },
          onDismissed: (DismissDirection direction) async {
            if (direction == DismissDirection.startToEnd) {
              // Delete
              context.read<FilterListBloc>().add(
                    FilterListFilterDeleted(filter: filter),
                  );
              SnackBarHandler.info(context, 'Filter has been deleted');
            }
          },
          child: ListTile(
            key: ValueKey<int>(filter.id!),
            title: Text(
              filter.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: _buildSubtitle(),
            onTap: () => context.pushNamed('filter-edit', extra: filter),
          ),
        );
      },
    );
  }

  Widget? _buildSubtitle() {
    final List<String> items = [
      filter.order.name,
      filter.filter.name,
      filter.group.name,
      for (Priority p in filter.priorities) p.name,
      for (String p in filter.projects) '+$p',
      for (String c in filter.contexts) '@$c',
    ]..removeWhere((value) => value.isEmpty);

    if (items.isEmpty) {
      return null;
    }

    List<String> shortenedItems;
    if (items.length > 5) {
      shortenedItems = items.sublist(0, 5);
      shortenedItems.add('...');
    } else {
      shortenedItems = [...items];
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        for (String attr in shortenedItems) BasicChip(label: attr, mono: true),
      ],
    );
  }
}
