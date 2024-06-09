import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_cubit.dart';
import 'package:ntodotxt/presentation/todo/states/todo_state.dart';

class TodoStringTextField extends StatefulWidget {
  const TodoStringTextField({super.key});

  @override
  State<TodoStringTextField> createState() => _TodoStringTextFieldState();
}

class _TodoStringTextFieldState extends State<TodoStringTextField> {
  late GlobalKey<FormFieldState> _textFormKey;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _textFormKey = GlobalKey<FormFieldState>();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (BuildContext context, TodoState state) {
        // Setting text and selection together.
        int base = _controller.selection.base.offset;
        _controller.value = _controller.value.copyWith(
          text: state.todo.description,
          selection: TextSelection.fromPosition(
            TextPosition(
              offset: base < 0 || base > state.todo.description.length
                  ? state.todo.description.length
                  : base,
            ),
          ),
        );
        return TextFormField(
          key: _textFormKey,
          controller: _controller,
          minLines: 1,
          maxLines: 3,
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\n')),
          ],
          style: Theme.of(context).textTheme.titleMedium,
          decoration: const InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            hintText: 'todo +project @context key:val',
          ),
          onChanged: (String value) =>
              context.read<TodoCubit>().updateDescription(_controller.text),
        );
      },
    );
  }
}
