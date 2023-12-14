import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show ListOrder;
import 'package:ntodotxt/presentation/default_filter/states/default_filter_cubit.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart'
    show TodoListBloc;

class OrderTodoListBottomSheet extends StatelessWidget {
  final Map<String, ListOrder> items;

  const OrderTodoListBottomSheet({super.key})
      : items = const {
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
      builder: (context) {
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(key),
              value: value,
              groupValue: context.read<TodoListBloc>().state.filter.order,
              onChanged: (ListOrder? value) {
                Navigator.pop(
                  context,
                  value ?? context.read<TodoListBloc>().state.filter.order,
                );
              },
            );
          },
        );
      },
    );
  }
}

class OrderSettingsDialog extends StatelessWidget {
  final Map<String, ListOrder> items;

  const OrderSettingsDialog({super.key})
      : items = const {
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            value: value,
            title: Text(key),
            groupValue: context.read<DefaultFilterCubit>().state.order,
            onChanged: (ListOrder? value) => Navigator.pop(context, value),
          );
        },
      ),
    );
  }
}
