import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/common/constants/app.dart';
import 'package:ntodotxt/common/misc.dart';
import 'package:ntodotxt/common/widget/app_bar.dart';
import 'package:ntodotxt/common/widget/info_dialog.dart';
import 'package:ntodotxt/login/state/login_cubit.dart';
import 'package:ntodotxt/todo_file/state/todo_file_cubit.dart';
import 'package:ntodotxt/todo_file/state/todo_file_state.dart';
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
    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return Stack(
      children: [
        Scaffold(
          appBar: const MainAppBar(title: 'Local'),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            children: [
              ListTile(
                title: Text(
                  'Todo',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const TodoFilenameInput(),
              const LocalPathInput(),
            ],
          ),
          floatingActionButton: keyboardIsOpen
              ? null
              : BlocBuilder<TodoFileCubit, TodoFileState>(
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
                                localTodoFilePath: state.localTodoFilePath,
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
  String path = '';
  String username = '';
  String password = '';
  bool acceptUntrustedCert = false;

  late GlobalKey<FormState> formKey;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setServerAddr(String value) => setState(() => serverAddr = value);

  void setAcceptUntrustedCert(bool value) =>
      setState(() => acceptUntrustedCert = value);

  void setBaseUrl(String value) => setState(() => path = value);

  void setUsername(String value) => setState(() => username = value);

  void setPassword(String value) => setState(() => password = value);

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;

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
            appBar: const MainAppBar(title: 'WebDAV'),
            body: Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                children: [
                  ListTile(
                    title: Text(
                      'Server connection',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  ServerAddrField(
                    callback: setServerAddr,
                  ),
                  AcceptUntrustedCertField(
                    callback: setAcceptUntrustedCert,
                  ),
                  BaseUrlField(
                    callback: setBaseUrl,
                  ),
                  UsernameField(
                    callback: setUsername,
                  ),
                  PasswordField(
                    callback: setPassword,
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(
                      'Todo',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const TodoFilenameInput(),
                  const LocalPathInput(),
                  const RemotePathInput(),
                  const SizedBox(height: 72),
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
                                    localTodoFilePath: state.localTodoFilePath,
                                    remoteTodoFilePath:
                                        state.remoteTodoFilePath,
                                    server: serverAddr,
                                    path: path,
                                    username: username,
                                    password: password,
                                    acceptUntrustedCert: acceptUntrustedCert,
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

class ServerAddrField extends StatefulWidget {
  final Function(String serverAddr) callback;

  const ServerAddrField({
    required this.callback,
    super.key,
  });

  @override
  State<ServerAddrField> createState() => _ServerAddrFieldState();
}

class _ServerAddrFieldState extends State<ServerAddrField> {
  late TextEditingController textFieldController;

  @override
  void initState() {
    super.initState();
    textFieldController = TextEditingController();
  }

  @override
  void dispose() {
    textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.dns),
      title: TextFormField(
        controller: textFieldController,
        style: Theme.of(context).textTheme.bodyMedium,
        textCapitalization: TextCapitalization.none,
        decoration: const InputDecoration(
          labelText: 'Server',
          hintText: 'http[s]://server[:port]',
        ),
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return 'Missing server address';
          }
          if (!value.startsWith('http://') && !value.startsWith('https://')) {
            return 'Missing protocol';
          }
          if (!RegExp(
                  r'(?<proto>^(http|https):\/\/)(?<host>[a-zA-Z0-9.-]+)(:(?<port>\d+)){0,1}$')
              .hasMatch(value)) {
            return 'Invalid format';
          }
          return null;
        },
        onChanged: (String value) => widget.callback(textFieldController.text),
      ),
    );
  }
}

class AcceptUntrustedCertField extends StatefulWidget {
  final Function(bool allowSelfSignedCert) callback;

  const AcceptUntrustedCertField({
    required this.callback,
    super.key,
  });

  @override
  State<AcceptUntrustedCertField> createState() =>
      _AcceptUntrustedCertFieldState();
}

class _AcceptUntrustedCertFieldState extends State<AcceptUntrustedCertField> {
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(!checked ? Icons.lock_outline : Icons.lock_open),
      title: const Text('Allow certificate'),
      subtitle: const Text('Auto-accept certificate'),
      trailing: Checkbox(
        value: checked,
        onChanged: (bool? value) {
          setState(() => checked = value ?? true);
          widget.callback(value ?? true);
        },
      ),
    );
  }
}

class BaseUrlField extends StatefulWidget {
  final Function(String path) callback;

  const BaseUrlField({
    required this.callback,
    super.key,
  });

  @override
  State<BaseUrlField> createState() => _BaseUrlFieldState();
}

class _BaseUrlFieldState extends State<BaseUrlField> {
  late TextEditingController textFieldController;

  @override
  void initState() {
    super.initState();
    textFieldController = TextEditingController();
  }

  @override
  void dispose() {
    textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.http),
      title: TextFormField(
        controller: textFieldController,
        style: Theme.of(context).textTheme.bodyMedium,
        textCapitalization: TextCapitalization.none,
        decoration: const InputDecoration(
          labelText: 'Path',
          hintText: '/remote.php/dav/files/<username>',
        ),
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return 'Missing path';
          }
          return null;
        },
        onChanged: (String value) => widget.callback(textFieldController.text),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.help_outline),
        onPressed: () => InfoDialog.dialog(
          context: context,
          title: 'Path',
          message:
              '''The username is not automatically appended to the path. In some cases path containing the username is expected, in others this causes an error.

Please check the requirements of your webdav server.''',
        ),
      ),
    );
  }
}

class UsernameField extends StatefulWidget {
  final Function(String username) callback;

  const UsernameField({
    required this.callback,
    super.key,
  });

  @override
  State<UsernameField> createState() => _UsernameFieldState();
}

class _UsernameFieldState extends State<UsernameField> {
  late TextEditingController textFieldController;

  @override
  void initState() {
    super.initState();
    textFieldController = TextEditingController();
  }

  @override
  void dispose() {
    textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: TextFormField(
        controller: textFieldController,
        style: Theme.of(context).textTheme.bodyMedium,
        textCapitalization: TextCapitalization.none,
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
        onChanged: (String value) => widget.callback(textFieldController.text),
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final Function(String password) callback;

  const PasswordField({
    required this.callback,
    super.key,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  late TextEditingController textFieldController;

  bool showPassword = false;

  @override
  void initState() {
    super.initState();
    textFieldController = TextEditingController();
  }

  @override
  void dispose() {
    textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.password),
      title: TextFormField(
        controller: textFieldController,
        style: Theme.of(context).textTheme.bodyMedium,
        textCapitalization: TextCapitalization.none,
        decoration: const InputDecoration(
          labelText: 'Password',
          hintText: 'Password',
        ),
        obscureText: !showPassword,
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return 'Missing password';
          }
          return null;
        },
        onChanged: (String value) => widget.callback(textFieldController.text),
      ),
      trailing: IconButton(
        icon: Icon(
          showPassword ? Icons.visibility_off : Icons.visibility,
        ),
        onPressed: () => setState(() => showPassword = !showPassword),
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
          leading: const Icon(Icons.folder),
          title: Text(
            'Local path',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          subtitle: Text(state.localPath),
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
                await Permission.manageExternalStorage.request().isGranted ||
                await Permission.storage.request().isGranted) {
              String? selectedDirectory =
                  await FilePicker.platform.getDirectoryPath();
              if (context.mounted) {
                // If user canceled the directory picker use app cache directory as fallback.
                await context
                    .read<TodoFileCubit>()
                    .saveLocalPath(selectedDirectory ?? state.localPath);
              }
            }
          },
        );
      },
    );
  }
}

class RemotePathInput extends StatefulWidget {
  const RemotePathInput({super.key});

  @override
  State<RemotePathInput> createState() => _RemotePathInputState();
}

class _RemotePathInputState extends State<RemotePathInput> {
  final TextEditingController controller = TextEditingController();
  final Debouncer debounce = Debouncer(milliseconds: 1000);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    debounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initial value
    controller.text = context.read<TodoFileCubit>().state.remotePath;
    return BlocBuilder<TodoFileCubit, TodoFileState>(
      builder: (BuildContext context, TodoFileState state) {
        return ListTile(
            leading: const Icon(Icons.folder),
            title: TextFormField(
              controller: controller,
              style: Theme.of(context).textTheme.bodyMedium,
              textCapitalization: TextCapitalization.none,
              decoration: const InputDecoration(
                labelText: 'Remote path',
                hintText: defaultRemoteTodoPath,
              ),
              onChanged: (String value) async {
                debounce.run(() async => await _save(context, value));
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => InfoDialog.dialog(
                context: context,
                title: 'Remote path',
                message:
                    'This remote path is appended to the base path of the server connection. This makes it possible to define a user-defined path for the todo files.',
              ),
            ));
      },
    );
  }

  Future<void> _save(BuildContext context, String value) async {
    if (value.isEmpty) {
      SnackBarHandler.info(
        context,
        'Empty remote path is not allowed. Using default one.',
      );
      await context.read<TodoFileCubit>().saveRemotePath(defaultRemoteTodoPath);
      controller.value = controller.value.copyWith(
        text: defaultRemoteTodoPath,
        selection:
            const TextSelection.collapsed(offset: defaultRemoteTodoPath.length),
      );
    } else {
      await context.read<TodoFileCubit>().saveRemotePath(value);
      controller.value = controller.value.copyWith(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
  }
}

class TodoFilenameInput extends StatefulWidget {
  const TodoFilenameInput({super.key});

  @override
  State<TodoFilenameInput> createState() => _TodoFilenameInputState();
}

class _TodoFilenameInputState extends State<TodoFilenameInput> {
  final TextEditingController controller = TextEditingController();
  final Debouncer debounce = Debouncer(milliseconds: 1000);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    debounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initial value
    controller.text = context.read<TodoFileCubit>().state.todoFilename;
    return BlocBuilder<TodoFileCubit, TodoFileState>(
      builder: (BuildContext context, TodoFileState state) {
        return ListTile(
          leading: const Icon(Icons.description),
          title: TextFormField(
            controller: controller,
            style: Theme.of(context).textTheme.bodyMedium,
            textCapitalization: TextCapitalization.none,
            decoration: const InputDecoration(
              labelText: 'Todo filename',
              hintText: defaultTodoFilename,
            ),
            onChanged: (String value) async {
              debounce.run(() async => await _save(context, value));
            },
          ),
        );
      },
    );
  }

  Future<void> _save(BuildContext context, String value) async {
    if (value.isEmpty) {
      SnackBarHandler.info(
        context,
        'Empty todo filename is not allowed. Using default one.',
      );
      await context
          .read<TodoFileCubit>()
          .saveLocalFilename(defaultTodoFilename);
      controller.value = controller.value.copyWith(
        text: defaultTodoFilename,
        selection:
            const TextSelection.collapsed(offset: defaultTodoFilename.length),
      );
    } else {
      await context.read<TodoFileCubit>().saveLocalFilename(value);
      controller.value = controller.value.copyWith(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
  }
}
