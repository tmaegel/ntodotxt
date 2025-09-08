import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/filter/model/filter_model.dart' show ListOrder;
import 'package:ntodotxt/filter/state/filter_cubit.dart';
import 'package:ntodotxt/filter/state/filter_state.dart';

class OrderSelector extends StatelessWidget {
  final Set<ListOrder> items;

  OrderSelector({super.key}) : items = ListOrder.values.toSet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      buildWhen: (FilterState previousState, FilterState state) =>
          previousState.filter.order != state.filter.order,
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
                selected: state.filter.order == i,
                showCheckmark: false,
                // Workaround: https://github.com/flutter/flutter/issues/67797
                visualDensity: const VisualDensity(
                  horizontal: -4.0,
                  vertical: -4.0,
                ),
                onSelected: (bool selected) =>
                    context.read<FilterCubit>().updateOrder(i),
              ),
          ],
        );
      },
    );
  }
}
