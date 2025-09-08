import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/filter/state/filter_cubit.dart';
import 'package:ntodotxt/filter/state/filter_state.dart';

class ProjectSelector extends StatelessWidget {
  final Set<String> items;
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;

  const ProjectSelector({
    required this.items,
    this.multiSelectionEnabled = true,
    this.emptySelectionAllowed = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      buildWhen: (FilterState previousState, FilterState state) =>
          previousState.filter.projects != state.filter.projects,
      builder: (BuildContext context, FilterState state) {
        if (items.isEmpty) {
          return Text(
            'No project tags available',
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
              for (var i in items.toList()..sort())
                ChoiceChip(
                  label: Text(i),
                  selected: state.filter.projects.contains(i),
                  showCheckmark: false,
                  // Workaround: https://github.com/flutter/flutter/issues/67797
                  visualDensity: const VisualDensity(
                    horizontal: -4.0,
                    vertical: -4.0,
                  ),
                  onSelected: (bool selected) {
                    if (multiSelectionEnabled) {
                      if (state.filter.projects.contains(i)) {
                        if (emptySelectionAllowed ||
                            state.filter.projects.length > 1) {
                          context.read<FilterCubit>().removeProject(i);
                        }
                      } else {
                        context.read<FilterCubit>().addProject(i);
                      }
                    } else {
                      if (selected) {
                        context.read<FilterCubit>().updateProjects({i});
                      } else {
                        if (emptySelectionAllowed) {
                          context.read<FilterCubit>().removeProject(i);
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
