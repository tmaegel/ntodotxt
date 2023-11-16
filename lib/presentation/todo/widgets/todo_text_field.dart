import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';

class TodoFullStringTextField extends StatelessWidget {
  const TodoFullStringTextField({super.key});

  @override
  Widget build(BuildContext context) {
    final FocusNode focusNode = FocusNode();
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (BuildContext context, TodoState state) {
        return GestureDetector(
          onTap: () => focusNode
              .requestFocus(), // Focus text field if click on container.
          child: Container(
            // Only if color is defined, the focus handler works.
            color: Colors.transparent,
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 4.0, // gap between adjacent chips
              runSpacing: 0.0, // gap between lines
              children: <Widget>[
                if (state.todo.completion == true)
                  _buildText(context, state.todo.formattedCompletion),
                if (state.todo.completionDate != null)
                  _buildText(context, state.todo.formattedCompletionDate),
                if (state.todo.priority != null)
                  _buildText(context, state.todo.formattedPriority),
                if (state.todo.creationDate != null)
                  _buildText(context, state.todo.formattedCreationDate),
                IntrinsicWidth(
                    child: TodoDescriptionTextField(focusNode: focusNode)),
                if (state.todo.projects.isNotEmpty)
                  _buildText(context, state.todo.formattedProjects.join(' ')),
                if (state.todo.contexts.isNotEmpty)
                  _buildText(context, state.todo.formattedContexts.join(' ')),
                if (state.todo.keyValues.isNotEmpty)
                  _buildText(context, state.todo.formattedKeyValues.join(' ')),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildText(BuildContext context, String value) {
    return Text(
      value,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

class TodoDescriptionTextField extends StatefulWidget {
  final FocusNode focusNode;

  const TodoDescriptionTextField({required this.focusNode, super.key});

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
          focusNode: widget.focusNode,
          controller: _controller,
          minLines: 1,
          maxLines: 5,
          style: Theme.of(context).textTheme.titleMedium,
          decoration: const InputDecoration(
            isDense: true,
            filled: false,
            contentPadding: EdgeInsets.zero,
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
