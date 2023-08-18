import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';

class OrderDialog extends StatelessWidget {
  const OrderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      buildWhen: (TodoListState previousState, TodoListState state) {
        // Rebuild if order is changed only.
        return previousState.order != state.order;
      },
      builder: (BuildContext context, TodoListState state) {
        return SimpleDialog(
          title: const Text('Select order'),
          children: [
            ListTile(
              title: const Text('Ascending'),
              leading: Radio<TodoListOrder>(
                value: TodoListOrder.ascending,
                groupValue: state.order,
                onChanged: (TodoListOrder? value) => _setState(context, value),
              ),
            ),
            ListTile(
              title: const Text('Descending'),
              leading: Radio<TodoListOrder>(
                value: TodoListOrder.descending,
                groupValue: state.order,
                onChanged: (TodoListOrder? value) => _setState(context, value),
              ),
            ),
          ],
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