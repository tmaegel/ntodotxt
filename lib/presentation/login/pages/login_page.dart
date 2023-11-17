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
        action: () => context.read<AuthCubit>().loginOffline(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class WebDAVLoginView extends StatelessWidget {
  final TextEditingController serverTextFieldController =
      TextEditingController();
  final TextEditingController usernameTextFieldController =
      TextEditingController();
  final TextEditingController passwordTextFieldController =
      TextEditingController();

  WebDAVLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48.0),
        child: Form(
          key: GlobalKey<FormState>(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: serverTextFieldController,
                  decoration: const InputDecoration(
                    labelText: 'Server',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: usernameTextFieldController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: passwordTextFieldController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
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
          context.read<AuthCubit>().loginWebDAV(
                server: serverTextFieldController.text,
                username: usernameTextFieldController.text,
                password: passwordTextFieldController.text,
              );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
