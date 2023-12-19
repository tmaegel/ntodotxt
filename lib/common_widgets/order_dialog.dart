import 'package:flutter/material.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show ListOrder;
import 'package:ntodotxt/presentation/default_filter/states/default_filter_cubit.dart'
    show DefaultFilterCubit;
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart'
    show FilterCubit;

class OrderTodoListBottomSheet extends StatelessWidget {
  final FilterCubit cubit;
  final Map<String, ListOrder> items;

  const OrderTodoListBottomSheet({
    required this.cubit,
    super.key,
  }) : items = const {
          'Ascending': ListOrder.ascending,
          'Descending': ListOrder.descending,
        };

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      key: const Key('OrderTodoListBottomSheet'),
      enableDrag: false,
      showDragHandle: false,
      onClosing: () {},
      builder: (BuildContext context) {
        return ListView.builder(
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
        );
      },
    );
  }
}

class OrderSettingsDialog extends StatelessWidget {
  final DefaultFilterCubit cubit;
  final Map<String, ListOrder> items;

  const OrderSettingsDialog({
    required this.cubit,
    super.key,
  }) : items = const {
          'Ascending': ListOrder.ascending,
          'Descending': ListOrder.descending,
        };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key('OrderSettingsDialog'),
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
                cubit.updateListOrder(value);
              }
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
