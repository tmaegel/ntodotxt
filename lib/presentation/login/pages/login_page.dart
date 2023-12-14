import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/config/theme/theme.dart' show lightTheme, darkTheme;
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/main.dart' show App, log;
import 'package:ntodotxt/misc.dart' show SnackBarHandler;
import 'package:ntodotxt/presentation/login/states/login_cubit.dart';
import 'package:ntodotxt/presentation/login/states/login_state.dart';

class LoginWrapper extends StatelessWidget {
  final File todoFile;
  final LoginState initialLoginState;

  const LoginWrapper({
    required this.todoFile,
    required this.initialLoginState,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => LoginCubit(
        state: initialLoginState,
      ),
      child: BlocConsumer<LoginCubit, LoginState>(
        listenWhen: (LoginState previous, LoginState current) =>
            current is LoginError,
        listener: (BuildContext context, LoginState state) {
          if (state is LoginError) {
            SnackBarHandler.error(context, state.message);
          }
        },
        buildWhen: (previousState, state) =>
            (previousState is Logout && state is! Logout) ||
            (previousState is! Logout && state is Logout),
        builder: (BuildContext context, LoginState state) {
          if (state is Logout) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: ThemeMode.system,
              home: const LoginPage(),
            );
          } else {
            return RepositoryProvider(
              create: (BuildContext context) {
                log.info('Create repository');
                return TodoListRepository(api: _createApi(state));
              },
              child: const App(),
            );
          }
        },
      ),
    );
  }

  TodoListApi _createApi(LoginState loginState) {
    switch (loginState) {
      case LoginOffline():
        log.info('Use local backend');
        return LocalTodoListApi(todoFile: todoFile);
      case LoginWebDAV():
        log.info('Use local+webdav backend');
        return WebDAVTodoListApi(
          todoFile: todoFile,
          server: loginState.server,
          baseUrl: loginState.baseUrl,
          username: loginState.username,
          password: loginState.password,
        );
      default:
        log.info('Fallback to local backend');
        return LocalTodoListApi(todoFile: todoFile);
    }
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: PrimaryFloatingActionButton(
                icon: const Icon(Icons.cloud_off),
                tooltip: 'Use this app offline',
                label: 'Offline',
                action: () => context.read<LoginCubit>().loginOffline(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 150,
              child: PrimaryFloatingActionButton(
                icon: const Icon(Icons.cloud_outlined),
                tooltip: 'Login via WebDAV',
                label: 'WebDAV',
                action: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return WebDAVLoginView();
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LocalLoginView extends StatelessWidget {
  const LocalLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Offline usage'),
      ),
      floatingActionButton: PrimaryFloatingActionButton(
        icon: const Icon(Icons.check),
        tooltip: 'Continue',
        label: 'Continue',
        action: () => context.read<LoginCubit>().loginOffline(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class WebDAVLoginView extends StatelessWidget {
  final TextEditingController serverTextFieldController =
      TextEditingController();
  final TextEditingController baseUrlTextFieldController =
      TextEditingController();
  final TextEditingController usernameTextFieldController =
      TextEditingController();
  final TextEditingController passwordTextFieldController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  WebDAVLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: 'Login - WebDAV'),
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            ListTile(
              title: TextFormField(
                controller: serverTextFieldController,
                decoration: const InputDecoration(
                  labelText: 'Server',
                  hintText: 'http[s]://<server>:<port>',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Missing server address';
                  }
                  if (!value.startsWith('http://') &&
                      !value.startsWith('https://')) {
                    return 'Missing protocol';
                  }
                  final strippedValue = value
                      .replaceAll('http://', '')
                      .replaceAll('https://', '');
                  if (strippedValue.split(':').length < 2) {
                    return 'Missing server port';
                  }
                  if (!RegExp(
                          r'(?<proto>^(http|https):\/\/)(?<host>\w+):(?<port>\d+)$')
                      .hasMatch(value)) {
                    return 'Invalid format';
                  }
                  return null;
                },
              ),
            ),
            ListTile(
              title: TextFormField(
                controller: baseUrlTextFieldController,
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
              ),
            ),
            ListTile(
              title: TextFormField(
                controller: usernameTextFieldController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Missing username';
                  }
                  return null;
                },
              ),
            ),
            ListTile(
              title: TextFormField(
                controller: passwordTextFieldController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Missing password';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: PrimaryFloatingActionButton(
        icon: const Icon(Icons.cloud_outlined),
        tooltip: 'Login',
        label: 'Login',
        action: () {
          // Validate returns true if the form is valid, or false otherwise.
          if (formKey.currentState!.validate()) {
            context.read<LoginCubit>().loginWebDAV(
                  server: serverTextFieldController.text,
                  baseUrl: baseUrlTextFieldController.text,
                  username: usernameTextFieldController.text,
                  password: passwordTextFieldController.text,
                );
          }
        },
      ),
    );
  }
}
