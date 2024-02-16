import 'package:flutter/material.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show ListOrder;
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart'
    show FilterCubit;

class FilterStateOrderDialog extends StatelessWidget {
  final FilterCubit cubit;
  final Map<String, ListOrder> items;

  const FilterStateOrderDialog({
    required this.cubit,
    super.key,
  }) : items = const {
          'Ascending': ListOrder.ascending,
          'Descending': ListOrder.descending,
        };

  static Future<void> dialog({
    required BuildContext context,
    required FilterCubit cubit,
  }) async {
    return await showDialog<Future<void>>(
      context: context,
      builder: (BuildContext context) => FilterStateOrderDialog(cubit: cubit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          String key = items.keys.elementAt(index);
          ListOrder value = items[key]!;
          return RadioListTile<ListOrder>(
            key: Key('${value.name}BottomSheetRadioButton'),
            contentPadding: EdgeInsets.zero,
            title: Text(key),
            value: value,
            groupValue: cubit.state.filter.order,
            onChanged: (ListOrder? value) {
              if (value != null) {
                cubit.updateOrder(value);
              }
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}

class DefaultFilterStateOrderDialog extends StatelessWidget {
  final FilterCubit cubit;
  final Map<String, ListOrder> items;

  const DefaultFilterStateOrderDialog({
    required this.cubit,
    super.key,
  }) : items = const {
          'Ascending': ListOrder.ascending,
          'Descending': ListOrder.descending,
        };

  static Future<void> dialog({
    required BuildContext context,
    required FilterCubit cubit,
  }) async {
    return await showDialog<Future<void>>(
      context: context,
      builder: (BuildContext context) =>
          DefaultFilterStateOrderDialog(cubit: cubit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          String key = items.keys.elementAt(index);
          ListOrder value = items[key]!;
          return RadioListTile<ListOrder>(
            key: Key('${value.name}DialogRadioButton'),
            contentPadding: EdgeInsets.zero,
            value: value,
            title: Text(key),
            groupValue: cubit.state.filter.order,
            onChanged: (ListOrder? value) {
              if (value != null) {
                cubit.updateDefaultOrder(value);
              }
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
