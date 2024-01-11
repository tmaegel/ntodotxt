import 'package:flutter/material.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority;
import 'package:ntodotxt/presentation/todo/states/todo_cubit.dart';

class PriorityDialog extends StatelessWidget {
  final TodoCubit cubit;
  final Map<String, Priority> items;

  const PriorityDialog({
    required this.cubit,
    super.key,
  }) : items = const {
          'None': Priority.none,
          'A': Priority.A,
          'B': Priority.B,
          'C': Priority.C,
          'D': Priority.D,
          'E': Priority.E,
          'F': Priority.F,
        };

  static Future<void> dialog({
    required BuildContext context,
    required TodoCubit cubit,
  }) async {
    return await showDialog<Future<void>>(
      context: context,
      builder: (BuildContext context) => PriorityDialog(cubit: cubit),
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
          Priority value = items[key]!;
          return RadioListTile<Priority>(
            key: Key('${value.name}BottomSheetRadioButton'),
            contentPadding: EdgeInsets.zero,
            title: Text(key),
            value: value,
            groupValue: cubit.state.todo.priority,
            onChanged: (Priority? value) {
              if (value != null) {
                cubit.setPriority(value);
              }
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
