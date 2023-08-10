import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/common_widgets/header.dart';
import 'package:ntodotxt/constants/screen.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/presentation/todo/states/todo_mode_cubit.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: MainAppBar(
        title: "Create",
        leadingAction: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _cancelAction(context),
        ),
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
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xfff1f1f1),
              ),
            ),
            const Subheader(title: "Priority"),
            GenericChipGroup(
              chips: [
                for (var p in todoListRepository.getAllPriorities())
                  ChipEntity(label: p),
              ],
            ),
            const Subheader(title: "Projects"),
            GenericChipGroup(
              chips: [
                for (var p in todoListRepository.getAllProjects())
                  ChipEntity(label: p),
              ],
            ),
            const Subheader(title: "Contexts"),
            GenericChipGroup(
              chips: [
                for (var p in todoListRepository.getAllContexts())
                  ChipEntity(label: p),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: screenWidth < maxScreenWidthCompact
          ? _buildFloatingActionButton(context)
          : null,
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.save),
      tooltip: 'Save',
      action: () => _primaryAction(context),
    );
  }

  /// Save new todo
  void _primaryAction(BuildContext context) {
    context.go(context.namedLocation('todo-list'));
  }

  /// Cancel current create process
  void _cancelAction(BuildContext context) {
    context.read<TodoModeCubit>().list();
    context.go(context.namedLocation('todo-list'));
  }
}
