import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/filter/model/filter_model.dart' show ListFilter;
import 'package:ntodotxt/filter/state/filter_cubit.dart';
import 'package:ntodotxt/filter/state/filter_state.dart';

class FilterSelector extends StatelessWidget {
  final Set<ListFilter> items;

  FilterSelector({super.key}) : items = ListFilter.values.toSet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      buildWhen: (FilterState previousState, FilterState state) =>
          previousState.filter.filter != state.filter.filter,
      builder: (BuildContext context, FilterState state) {
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
                selected: state.filter.filter == i,
                showCheckmark: false,
                // Workaround: https://github.com/flutter/flutter/issues/67797
                visualDensity: const VisualDensity(
                  horizontal: -4.0,
                  vertical: -4.0,
                ),
                onSelected: (bool selected) =>
                    context.read<FilterCubit>().updateFilter(i),
              ),
          ],
        );
      },
    );
  }
}
