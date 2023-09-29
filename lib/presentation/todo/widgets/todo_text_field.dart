import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';

class TodoDescriptionTextField extends StatefulWidget {
  const TodoDescriptionTextField({super.key});

  @override
  State<TodoDescriptionTextField> createState() =>
      _TodoDescriptionTextFieldState();
}

class _TodoDescriptionTextFieldState extends State<TodoDescriptionTextField> {
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
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        // Rebuild if description has changed only.
        return previousState.todo.description != state.todo.description;
      },
      builder: (BuildContext context, TodoState state) {
        _controller.text = state.todo.description; // Initial value.
        return TextFormField(
          key: _textFormKey,
          controller: _controller,
          minLines: 1,
          maxLines: 5,
          style: Theme.of(context).textTheme.titleMedium,
          decoration: const InputDecoration(
            hintText: 'Enter your todo description here ...',
            isDense: true,
            filled: false,
            contentPadding: EdgeInsets.all(20.0),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          onChanged: (value) {
            context
                .read<TodoBloc>()
                .add(TodoDescriptionChanged(_controller.text));
          },
        );
      },
    );
  }
}
