import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/backend_dialog.dart';
import 'package:ntodotxt/common_widgets/filter_dialog.dart';
import 'package:ntodotxt/common_widgets/group_by_dialog.dart';
import 'package:ntodotxt/common_widgets/order_dialog.dart';
import 'package:ntodotxt/presentation/login/states/login_cubit.dart';
import 'package:ntodotxt/presentation/login/states/login_state.dart';
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
    return Builder(builder: (BuildContext context) {
      final authState = context.watch<AuthCubit>().state;
      final settingsState = context.watch<SettingsCubit>().state;
      // Return a Widget which depends on the state
      // of SettingsCubit and AuthCubit.
      return ListView(
        children: [
          ListTile(
            title: Text(
              'General',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ListTile(
            title: const Text("Backend"),
            subtitle: Text(authState.backend.name),
            onTap: () async {
              context.read<AuthCubit>().updateBackend(
                    await showDialog<Backend?>(
                      context: context,
                      builder: (BuildContext context) =>
                          const BackendSettingsDialog(),
                    ),
                  );
            },
          ),
          if (authState is WebDAVLogin)
            ListTile(
              title: const Text("Server"),
              subtitle: Text(authState.server),
              onTap: () async => context.read<AuthCubit>().updateWebDAVServer(
                    await _askedForTextInput(
                        context: context,
                        label: "Enter WebDAV server",
                        value: authState.server),
                  ),
            ),
          if (authState is WebDAVLogin)
            ListTile(
              title: const Text("Username"),
              subtitle: Text(authState.username),
              onTap: () async => context.read<AuthCubit>().updateWebDAVUsername(
                    await _askedForTextInput(
                        context: context,
                        label: "Enter WebDAV username",
                        value: authState.username),
                  ),
            ),
          if (authState is WebDAVLogin)
            ListTile(
              title: const Text("Password"),
              subtitle: Text(authState.password),
              onTap: () async => context.read<AuthCubit>().updateWebDAVPassword(
                    await _askedForTextInput(
                        context: context,
                        label: "Enter WebDAV username",
                        value: authState.password),
                  ),
            ),
          const Divider(),
          ListTile(
            title: Text(
              'Todo',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ListTile(
            title: const Text("Todo filename (default: todo.txt)"),
            subtitle: Text(settingsState.todoFilename),
            onTap: () async => context.read<SettingsCubit>().updateTodoFilename(
                  await _askedForTextInput(
                      context: context,
                      label: "Enter filename",
                      value: settingsState.todoFilename),
                ),
          ),
          ListTile(
            title: const Text("Done filename (default: done.txt)"),
            subtitle: Text(settingsState.doneFilename),
            onTap: () async => context.read<SettingsCubit>().updateDoneFilename(
                  await _askedForTextInput(
                      context: context,
                      label: "Enter filename",
                      value: settingsState.doneFilename),
                ),
          ),
          const Divider(),
          ListTile(
            title: Text(
              'Display',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ListTile(
            title: const Text("Filter"),
            subtitle: Text(settingsState.todoFilter),
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
            subtitle: Text(settingsState.todoOrder),
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
            subtitle: Text(settingsState.todoGrouping),
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
            title: const Text("Auto archiving"),
            subtitle:
                const Text("Automatically move done todos to the done file."),
            trailing: Switch(
              value: settingsState.autoArchive,
              onChanged: (bool value) =>
                  context.read<SettingsCubit>().toggleAutoArchive(value),
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(
              'Import & Export',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ListTile(
            title: const Text("Backup settings"),
            subtitle: const Text("Backup app settings to file."),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Restore settings"),
            subtitle: const Text("Restore app settings from file."),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            title: Text(
              'Others',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ListTile(
            title: const Text("Reset app settings"),
            subtitle: const Text(
                'Resets setting to the defaults. This also disconnects the connection to the backend. Todos will not be deleted.'),
            onTap: () {
              context.read<SettingsCubit>().resetSettings();
              context.read<AuthCubit>().logout();
            },
          ),
          ListTile(
            title: const Text('About'),
            onTap: () => context.pushNamed("app-info"),
          ),
        ],
      );
    });
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
          label,
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
