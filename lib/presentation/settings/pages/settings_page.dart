import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/filter_dialog.dart';
import 'package:ntodotxt/common_widgets/group_by_dialog.dart';
import 'package:ntodotxt/common_widgets/order_dialog.dart';
import 'package:ntodotxt/presentation/settings/states/settings.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "Settings",
        leadingAction: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _cancelAction(context),
        ),
      ),
      body: const SettingsView(),
    );
  }

  void _cancelAction(BuildContext context) => context.pop();
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (BuildContext context, SettingsState state) {
        return ListView(
          children: [
            ListTile(
              title: Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            ListTile(
              title: const Text("Filter"),
              subtitle: Text(state.todoFilter),
              onTap: () async {
                context.read<SettingsCubit>().updateTodoFilter(
                      await showDialog<TodoListFilter?>(
                        context: context,
                        builder: (BuildContext context) =>
                            const FilterSettingsDialog(),
                      ),
                    );
              },
            ),
            ListTile(
              title: const Text("Order"),
              subtitle: Text(state.todoOrder),
              onTap: () async {
                context.read<SettingsCubit>().updateTodoOrder(
                      await showDialog<TodoListOrder?>(
                        context: context,
                        builder: (BuildContext context) =>
                            const OrderSettingsDialog(),
                      ),
                    );
              },
            ),
            ListTile(
              title: const Text("Group by"),
              subtitle: Text(state.todoGrouping),
              onTap: () async {
                context.read<SettingsCubit>().updateTodoGrouping(
                      await showDialog<TodoListGroupBy?>(
                        context: context,
                        builder: (BuildContext context) =>
                            const GroupBySettingsDialog(),
                      ),
                    );
              },
            ),
            ListTile(
              title: Text(
                'Todo',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            ListTile(
              title: const Text("Todo filename (default: todo.txt)"),
              subtitle: Text(state.todoFilename),
              onTap: () async =>
                  context.read<SettingsCubit>().updateTodoFilename(
                        await _askedForTextInput(
                            context: context,
                            label: "filename",
                            value: state.todoFilename),
                      ),
            ),
            ListTile(
              title: const Text("Done filename (default: done.txt)"),
              subtitle: Text(state.doneFilename),
              onTap: () async =>
                  context.read<SettingsCubit>().updateDoneFilename(
                        await _askedForTextInput(
                            context: context,
                            label: "filename",
                            value: state.doneFilename),
                      ),
            ),
            ListTile(
              title: const Text("Auto archiving"),
              subtitle:
                  const Text("Automatically move done todos to the done file."),
              trailing: Switch(
                value: state.autoArchive,
                onChanged: (bool value) =>
                    context.read<SettingsCubit>().toggleAutoArchive(value),
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(
                'Others',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            ListTile(
              title: const Text('About'),
              onTap: () => context.goNamed("app-info"),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _askedForTextInput({
    required BuildContext context,
    required String label,
    String? value,
  }) async {
    TextEditingController controller = TextEditingController(text: value);
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Enter $label',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
