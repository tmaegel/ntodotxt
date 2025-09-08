import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/filter/state/filter_cubit.dart';
import 'package:ntodotxt/filter/state/filter_state.dart';
import 'package:ntodotxt/todo/model/todo_model.dart' show Priority;

class PrioritySelector extends StatelessWidget {
  late final Set<Priority> items;
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;

  PrioritySelector({
    Set<Priority>? items,
    this.multiSelectionEnabled = true,
    this.emptySelectionAllowed = true,
    super.key,
  }) : items = (items ?? Priority.values.toSet()) {
    if (items != null) {
      items.toList().sort(
            (Priority a, Priority b) => a.toString().compareTo(b.toString()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      buildWhen: (FilterState previousState, FilterState state) =>
          previousState.filter.priorities != state.filter.priorities,
      builder: (BuildContext context, FilterState state) {
        if (items.isEmpty) {
          return Text(
            'No priorities available',
            style: TextStyle(fontStyle: FontStyle.italic),
          );
        } else {
          return Wrap(
            spacing: 4.0, // gap between adjacent chips
            alignment: WrapAlignment.start,
            runSpacing: 4.0, // gap between lines
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              for (var i in items)
                ChoiceChip(
                  label: Text(i.name),
                  selected: state.filter.priorities.contains(i),
                  showCheckmark: false,
                  // Workaround: https://github.com/flutter/flutter/issues/67797
                  visualDensity: const VisualDensity(
                    horizontal: -4.0,
                    vertical: -4.0,
                  ),
                  onSelected: (bool selected) {
                    if (multiSelectionEnabled) {
                      if (state.filter.priorities.contains(i)) {
                        if (emptySelectionAllowed ||
                            state.filter.priorities.length > 1) {
                          context.read<FilterCubit>().removePriority(i);
                        }
                      } else {
                        context.read<FilterCubit>().addPriority(i);
                      }
                    } else {
                      if (selected) {
                        context.read<FilterCubit>().updatePriorities({i});
                      } else {
                        if (emptySelectionAllowed) {
                          context.read<FilterCubit>().removePriority(i);
                        }
                      }
                    }
                  },
                ),
            ],
          );
        }
      },
    );
  }
}
