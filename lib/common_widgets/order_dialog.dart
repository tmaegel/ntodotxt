import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';

class OrderDialog extends StatelessWidget {
  final Map<String, TodoListOrder> items;

  const OrderDialog({super.key})
      : items = const {
          'Ascending': TodoListOrder.ascending,
          'Descending': TodoListOrder.descending,
        };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      buildWhen: (TodoListState previousState, TodoListState state) {
        // Rebuild if order is changed only.
        return previousState.order != state.order;
      },
      builder: (BuildContext context, TodoListState state) {
        return BottomSheet(
          key: const Key("orderDialog"),
          enableDrag: false,
          showDragHandle: false,
          onClosing: () {},
          builder: (context) {
            return ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                String key = items.keys.elementAt(index);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(key),
                  leading: Radio<TodoListOrder>(
                    key: Key('${items[key]!.name}RadioButton'),
                    value: items[key]!,
                    groupValue: state.order,
                    onChanged: (TodoListOrder? value) =>
                        _setState(context, value),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _setState(BuildContext context, TodoListOrder? order) {
    if (order != null) {
      context.read<TodoListBloc>().add(TodoListOrderChanged(order: order));
    }
    Navigator.pop(context);
  }
}
