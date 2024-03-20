import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/contexts_dialog.dart';
import 'package:ntodotxt/common_widgets/filter_dialog.dart';
import 'package:ntodotxt/common_widgets/group_by_dialog.dart';
import 'package:ntodotxt/common_widgets/order_dialog.dart';
import 'package:ntodotxt/common_widgets/priorities_dialog.dart';
import 'package:ntodotxt/common_widgets/projects_dialog.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart'
    show ListFilter, ListOrder;
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority;
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_state.dart';

class FilterOrderChip extends StatelessWidget {
  const FilterOrderChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (BuildContext context, FilterState state) {
        final bool changed = state.orderChanged;
        return GenericActionChip(
          avatar: const Icon(Icons.sort_by_alpha),
          label: Row(
            children: <Widget>[
              Text(state.filter.order == ListOrder.ascending ? 'asc' : 'desc'),
              const Text(' '),
              Icon(
                state.filter.order == ListOrder.ascending
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 18.0,
              ),
            ],
          ),
          selected: changed,
          onPressed: () async {
            await FilterStateOrderDialog.dialog(
              context: context,
              cubit: BlocProvider.of<FilterCubit>(context),
            );
          },
        );
      },
    );
  }
}

class FilterFilterChip extends StatelessWidget {
  const FilterFilterChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (BuildContext context, FilterState state) {
        final bool changed = state.filterChanged;
        late final String label;
        late final IconData iconData;
        switch (state.filter.filter) {
          case ListFilter.all:
            label = 'all';
            iconData = Icons.filter_list;
            break;
          case ListFilter.completedOnly:
            label = 'completed';
            iconData = Icons.done_all;
            break;
          case ListFilter.incompletedOnly:
            label = 'incompleted';
            iconData = Icons.remove_done;
            break;
        }

        return GenericActionChip(
          avatar: Icon(iconData),
          label: Text(label),
          selected: changed,
          onPressed: () async {
            await FilterStateFilterDialog.dialog(
              context: context,
              cubit: BlocProvider.of<FilterCubit>(context),
            );
          },
        );
      },
    );
  }
}

class FilterGroupChip extends StatelessWidget {
  const FilterGroupChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (BuildContext context, FilterState state) {
        final bool changed = state.groupChanged;
        return GenericActionChip(
          avatar: Icon(changed ? Icons.workspaces : Icons.workspaces_outlined),
          label: Text(state.filter.group.name),
          selected: changed,
          onPressed: () async {
            await FilterStateGroupDialog.dialog(
              context: context,
              cubit: BlocProvider.of<FilterCubit>(context),
            );
          },
        );
      },
    );
  }
}

class FilterPrioritiesChip extends StatelessWidget {
  const FilterPrioritiesChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (BuildContext context, FilterState state) {
        final bool changed = state.prioritiesChanged;
        return GenericActionChip(
          avatar: Icon(changed ? Icons.flag : Icons.flag_outlined),
          label: const Text('priorities'),
          selected: changed,
          onPressed: () async {
            await FilterPriorityTagDialog.dialog(
              context: context,
              cubit: BlocProvider.of<FilterCubit>(context),
              availableTags: Priority.values.toSet(),
            );
          },
        );
      },
    );
  }
}

class FilterProjectsChip extends StatelessWidget {
  final Set<String> availableTags;

  const FilterProjectsChip({
    this.availableTags = const {},
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (BuildContext context, FilterState state) {
        final bool changed = state.projectsChanged;
        return GenericActionChip(
          avatar: Icon(
              changed ? Icons.rocket_launch : Icons.rocket_launch_outlined),
          label: const Text('projects'),
          selected: changed,
          onPressed: () async {
            await FilterProjectTagDialog.dialog(
              context: context,
              cubit: BlocProvider.of<FilterCubit>(context),
              availableTags: {...availableTags, ...state.filter.projects},
            );
          },
        );
      },
    );
  }
}

class FilterContextsChip extends StatelessWidget {
  final Set<String> availableTags;

  const FilterContextsChip({
    this.availableTags = const {},
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (BuildContext context, FilterState state) {
        final bool changed = state.contextsChanged;
        return GenericActionChip(
          avatar: const Icon(Icons.tag),
          label: const Text('contexts'),
          selected: changed,
          onPressed: () async {
            await FilterContextTagDialog.dialog(
              context: context,
              cubit: BlocProvider.of<FilterCubit>(context),
              availableTags: {...availableTags, ...state.filter.contexts},
            );
          },
        );
      },
    );
  }
}
