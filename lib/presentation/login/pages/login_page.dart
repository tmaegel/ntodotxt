import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/presentation/login/states/login.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(MediaQuery.of(context).size.height),
            child: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.cloud_outlined),
                  text: 'WebDAV',
                ),
                Tab(
                  icon: Icon(Icons.cloud_off),
                  text: 'Offline',
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              WebDAVLoginView(),
              const LocalLoginView(),
            ],
          ),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
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
                            r"(?<proto>^(http|https):\/\/)(?<host>\w+):(?<port>\d+)$")
                        .hasMatch(value)) {
                      return 'Invalid format';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: passwordTextFieldController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
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
      ),
      floatingActionButton: PrimaryFloatingActionButton(
        icon: const Icon(Icons.login),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
