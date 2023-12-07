import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Todo;
import 'package:ntodotxt/presentation/todo/states/todo_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_event.dart'
    show TodoRefreshed;
import 'package:ntodotxt/presentation/todo/states/todo_state.dart';

class Debouncer {
  Timer? _timer;
  final int milliseconds;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

class TodoStringTextField extends StatefulWidget {
  const TodoStringTextField({super.key});

  @override
  State<TodoStringTextField> createState() => _TodoStringTextFieldState();
}

class _TodoStringTextFieldState extends State<TodoStringTextField> {
  late GlobalKey<FormFieldState> _textFormKey;
  late TextEditingController _controller;
  late Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _textFormKey = GlobalKey<FormFieldState>();
    _controller = TextEditingController();
    _debouncer = Debouncer(milliseconds: 750);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (BuildContext context, TodoState state) {
        _controller.text = state.todo.toString(includeId: false);
        return TextFormField(
          key: _textFormKey,
          controller: _controller,
          minLines: 1,
          maxLines: 5,
          enableInteractiveSelection: true,
          enableSuggestions: false,
          enableIMEPersonalizedLearning: false,
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r"\n")),
          ],
          style: Theme.of(context).textTheme.titleMedium,
          decoration: const InputDecoration(
            isDense: true,
            filled: false,
            contentPadding: EdgeInsets.all(16),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          onChanged: (String value) {
            _debouncer.run(
              () {
                final Todo todo = Todo.fromString(
                  byPassId: state.todo.id, // Bypass current id.
                  value: _controller.text,
                );
                context.read<TodoBloc>().add(TodoRefreshed(todo));
              },
            );
          },
          onTapOutside: (event) {
            final Todo todo = Todo.fromString(
              byPassId: state.todo.id, // Bypass current id.
              value: _controller.text,
            );
            context.read<TodoBloc>().add(TodoRefreshed(todo));
          },
        );
      },
    );
  }
}
