import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';

class FilterDialog extends StatelessWidget {
  final Map<String, TodoListFilter> items;

  const FilterDialog({super.key})
      : items = const {
          'All': TodoListFilter.all,
          'Completed only': TodoListFilter.completedOnly,
          'Incompleted only': TodoListFilter.incompletedOnly,
        };

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
            return ListView.builder(
              shrinkWrap: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                String key = items.keys.elementAt(index);
                return ListTile(
                  title: Text(key),
                  leading: Radio<TodoListFilter>(
                    value: items[key]!,
                    groupValue: state.filter,
                    onChanged: (TodoListFilter? value) =>
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

  void _setState(BuildContext context, TodoListFilter? filter) {
    if (filter != null) {
      context.read<TodoListBloc>().add(TodoListFilterChanged(filter: filter));
    }
    Navigator.pop(context);
  }
}
