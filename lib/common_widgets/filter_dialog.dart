import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';

class FilterDialog extends StatelessWidget {
  const FilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      buildWhen: (TodoListState previousState, TodoListState state) {
        // Rebuild if filter is changed only.
        return previousState.filter != state.filter;
      },
      builder: (BuildContext context, TodoListState state) {
        return BottomSheet(
          enableDrag: false,
          showDragHandle: false,
          onClosing: () {},
          builder: (context) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ListTile(
                    title: const Text('All'),
                    leading: Radio<TodoListFilter>(
                      value: TodoListFilter.all,
                      groupValue: state.filter,
                      onChanged: (TodoListFilter? value) =>
                          _setState(context, value),
                    ),
                  ),
                  ListTile(
                    title: const Text('Completed only'),
                    leading: Radio<TodoListFilter>(
                      value: TodoListFilter.completedOnly,
                      groupValue: state.filter,
                      onChanged: (TodoListFilter? value) =>
                          _setState(context, value),
                    ),
                  ),
                  ListTile(
                    title: const Text('Incompleted only'),
                    leading: Radio<TodoListFilter>(
                      value: TodoListFilter.incompletedOnly,
                      groupValue: state.filter,
                      onChanged: (TodoListFilter? value) =>
                          _setState(context, value),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _setState(BuildContext context, TodoListFilter? filter) {
    if (filter != null) {
      context.read<TodoListBloc>().add(TodoListFilterChanged(filter: filter));
    }
    Navigator.pop(context);
  }
}
