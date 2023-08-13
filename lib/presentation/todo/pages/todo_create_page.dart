import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/header.dart';
import 'package:ntodotxt/constants/todo.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';

class TodoCreatePage extends StatelessWidget {
  const TodoCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TodoListRepository todoListRepository =
        context.read<TodoListRepository>();
    return TodoCreateView(todoListRepository: todoListRepository);
  }
}

class TodoCreateView extends StatelessWidget {
  final TodoListRepository todoListRepository;

  const TodoCreateView({
    required this.todoListRepository,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: MainAppBar(
        title: "Create",
        leadingAction: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _cancelAction(context),
        ),
        toolbar: _buildToolBar(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Subheader(title: "Todo"),
            TextField(
              minLines: 3,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const Subheader(title: "Priority"),
            GenericChipGroup(
              children: [
                for (var p in priorities)
                  GenericChip(
                    label: p,
                    color: priorityChipColor[p],
                  ),
              ],
            ),
            const Subheader(title: "Projects"),
            GenericChipGroup(
              children: [
                for (var p in todoListRepository.getAllProjects())
                  GenericChip(
                    label: p,
                    color: projectChipColor,
                  ),
              ],
            ),
            const Subheader(title: "Contexts"),
            GenericChipGroup(
              children: [
                for (var p in todoListRepository.getAllContexts())
                  GenericChip(
                    label: p,
                    color: contextChipColor,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolBar(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: 'Save',
          icon: const Icon(Icons.save),
          onPressed: () => _saveAction(context),
        ),
      ],
    );
  }

  /// Save new todo
  void _saveAction(BuildContext context) {
    context.go(context.namedLocation('todo-list'));
  }

  /// Cancel current create process
  void _cancelAction(BuildContext context) {
    context.go(context.namedLocation('todo-list'));
  }
}
