import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/presentation/settings/states/settings.dart';

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
                'About',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const ListTile(
              title: Text('Licences'),
              subtitle: Text('MIT License'),
            ),
            const ListTile(
              title: Text('Report error'),
              subtitle: Text('Requires a free GitHub account.'),
            ),
            const ListTile(
              title: Text('Contribution'),
              subtitle: Text('Contribute to the source code.'),
            ),
            const ListTile(
              title: Text('Version'),
              subtitle: Text('v0.0.1'),
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
