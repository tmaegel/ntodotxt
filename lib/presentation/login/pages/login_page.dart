import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/common_widgets/info_dialog.dart';
import 'package:ntodotxt/misc.dart';
import 'package:ntodotxt/presentation/login/states/login_cubit.dart';
import 'package:ntodotxt/presentation/todo_file/todo_file_cubit.dart';
import 'package:ntodotxt/presentation/todo_file/todo_file_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalLoginView extends StatefulWidget {
  const LocalLoginView({super.key});

  @override
  State<LocalLoginView> createState() => _LocalLoginViewState();
}

class _LocalLoginViewState extends State<LocalLoginView> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            titleSpacing: 0.0,
            title: const Text('Local'),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            children: const [
              LocalPathInput(),
            ],
          ),
          floatingActionButton: BlocBuilder<TodoFileCubit, TodoFileState>(
            builder: (BuildContext context, TodoFileState state) {
              return FloatingActionButton.extended(
                heroTag: 'localUsage',
                icon: const Icon(Icons.done),
                label: const Text('Apply'),
                tooltip: 'Apply',
                onPressed: () async {
                  try {
                    setState(() => loading = true);
                    await context.read<LoginCubit>().loginLocal(
                          todoFile: File(
                              '${state.localPath}${Platform.pathSeparator}${state.todoFilename}'),
                        );
                  } finally {
                    setState(() => loading = false);
                  }
                },
              );
            },
          ),
        ),
        if (loading)
          const Opacity(
            opacity: 0.8,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
        if (loading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}

class WebDAVLoginView extends StatefulWidget {
  const WebDAVLoginView({super.key});

  @override
  State<WebDAVLoginView> createState() => _WebDAVLoginViewState();
}

class _WebDAVLoginViewState extends State<WebDAVLoginView> {
  bool loading = false;
  String serverAddr = '';
  String baseUrl = '';
  String username = '';
  String password = '';

  late GlobalKey<FormState> formKey;
  late TextEditingController serverTextFieldController;
  late TextEditingController baseUrlTextFieldController;
  late TextEditingController usernameTextFieldController;
  late TextEditingController passwordTextFieldController;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    serverTextFieldController = TextEditingController();
    baseUrlTextFieldController = TextEditingController();
    usernameTextFieldController = TextEditingController();
    passwordTextFieldController = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    serverTextFieldController.dispose();
    baseUrlTextFieldController.dispose();
    usernameTextFieldController.dispose();
    passwordTextFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    serverTextFieldController.text = serverAddr;
    baseUrlTextFieldController.text = baseUrl;
    usernameTextFieldController.text = username;
    passwordTextFieldController.text = password;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              titleSpacing: 0.0,
              title: const Text('WebDAV'),
            ),
            body: Form(
              key: formKey,
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                children: [
                  const LocalPathInput(),
                  const Divider(),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                    leading: const Icon(Icons.dns),
                    title: TextFormField(
                      controller: serverTextFieldController,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: const InputDecoration(
                        labelText: 'Server',
                        hintText: 'http[s]://<server>[:<port>]',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Missing server address';
                        }
                        if (!value.startsWith('http://') &&
                            !value.startsWith('https://')) {
                          return 'Missing protocol';
                        }
                        if (!RegExp(
                                r'(?<proto>^(http|https):\/\/)(?<host>[a-zA-Z0-9.-]+)(:(?<port>\d+)){0,1}$')
                            .hasMatch(value)) {
                          return 'Invalid format';
                        }
                        return null;
                      },
                      onChanged: (String value) {
                        setState(() {
                          serverAddr = serverTextFieldController.text;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                    leading: const Icon(Icons.http),
                    title: TextFormField(
                      controller: baseUrlTextFieldController,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: const InputDecoration(
                        labelText: 'Base URL',
                        hintText: 'e.g. /remote.php/dav/files',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Missing base URL';
                        }
                        return null;
                      },
                      onChanged: (String value) {
                        setState(() {
                          baseUrl = baseUrlTextFieldController.text;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                    leading: const Icon(Icons.person),
                    title: TextFormField(
                      controller: usernameTextFieldController,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        hintText: 'Username',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Missing username';
                        }
                        return null;
                      },
                      onChanged: (String value) {
                        setState(() {
                          username = usernameTextFieldController.text;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                    leading: const Icon(Icons.password),
                    title: TextFormField(
                      controller: passwordTextFieldController,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Password',
                      ),
                      obscureText: true,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Missing password';
                        }
                        return null;
                      },
                      onChanged: (String value) {
                        setState(() {
                          password = passwordTextFieldController.text;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: keyboardIsOpen
                ? null
                : BlocBuilder<TodoFileCubit, TodoFileState>(
                    builder: (BuildContext context, TodoFileState state) {
                      return FloatingActionButton.extended(
                        heroTag: 'webdavUsage',
                        icon: const Icon(Icons.done),
                        label: const Text('Apply'),
                        tooltip: 'Apply',
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            try {
                              setState(() => loading = true);
                              await context.read<LoginCubit>().loginWebDAV(
                                    todoFile: File(
                                        '${state.localPath}${Platform.pathSeparator}${state.todoFilename}'),
                                    server: serverAddr,
                                    baseUrl: baseUrl,
                                    username: username,
                                    password: password,
                                  );
                            } finally {
                              setState(() => loading = false);
                            }
                          }
                        },
                      );
                    },
                  ),
          ),
          if (loading)
            const Opacity(
              opacity: 0.8,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (loading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class LocalPathInput extends StatelessWidget {
  const LocalPathInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoFileCubit, TodoFileState>(
      buildWhen: (TodoFileState previousState, TodoFileState state) =>
          previousState.localPath != state.localPath,
      builder: (BuildContext context, TodoFileState state) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          leading: const Icon(Icons.folder),
          title: Text(
            'Local path',
            style: state.localPath == null
                ? null
                : Theme.of(context).textTheme.bodySmall,
          ),
          subtitle: state.localPath != null ? Text(state.localPath!) : null,
          trailing: IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => InfoDialog.dialog(
              context: context,
              title: 'Local path',
              message: '''Choose a directory by tapping the current local path.

Use this option if it's important to you where your todos are stored on your device. Otherwise, the app's cache directory is used.''',
            ),
          ),
          onTap: () async {
            if (!PlatformInfo.isAppOS ||
                await Permission.manageExternalStorage.request().isGranted) {
              String fallbackDirectory =
                  (await getApplicationCacheDirectory()).path;
              String? selectedDirectory =
                  await FilePicker.platform.getDirectoryPath();
              if (context.mounted) {
                // If user canceled the directory picker use app cache directory as fallback.
                await context.read<TodoFileCubit>().updateLocalPath(
                    selectedDirectory ??
                        (state.localPath ?? fallbackDirectory));
              }
            }
          },
        );
      },
    );
  }
}
