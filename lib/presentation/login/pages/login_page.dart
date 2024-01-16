import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/login/states/login_cubit.dart';

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
              child: FloatingActionButton.extended(
                label: const Text('Offline'),
                tooltip: 'Use this app offline',
                icon: const Icon(Icons.cloud_off),
                onPressed: () => context.read<LoginCubit>().loginOffline(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 150,
              child: FloatingActionButton.extended(
                label: const Text('WebDAV'),
                tooltip: 'Login via WebDAV',
                icon: const Icon(Icons.cloud_outlined),
                onPressed: () {
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
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Continue'),
        tooltip: 'Continue',
        icon: const Icon(Icons.check),
        onPressed: () => context.read<LoginCubit>().loginOffline(),
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
      appBar: AppBar(
        titleSpacing: 0.0,
        title: const Text('Login - WebDAV'),
      ),
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
                          r'(?<proto>^(http|https):\/\/)(?<host>[a-zA-Z0-9.-]+):(?<port>\d+)$')
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
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Login'),
        tooltip: 'Login',
        icon: const Icon(Icons.cloud_outlined),
        onPressed: () {
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
