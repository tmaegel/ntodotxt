import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/main.dart' show secureStorage;
import 'package:ntodotxt/presentation/login/states/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    LoginState? state,
  }) : super(state ?? const LoginLoading());

  Future<void> login() async {
    try {
      emit(const LoginLoading());
      String? backendFromsecureStorage =
          await secureStorage.read(key: 'backend');
      Backend backend;

      if (backendFromsecureStorage == null) {
        return emit(const Logout());
      }

      try {
        backend = Backend.values.byName(backendFromsecureStorage);
      } on Exception {
        return emit(const Logout());
      }

      if (backend == Backend.none) {
        return emit(const Logout());
      }

      if (backend == Backend.offline) {
        return emit(const LoginOffline());
      }
      if (backend == Backend.webdav) {
        String? server = await secureStorage.read(key: 'server');
        String? baseUrl = await secureStorage.read(key: 'baseUrl');
        String? username = await secureStorage.read(key: 'username');
        String? password = await secureStorage.read(key: 'password');
        if (server != null &&
            baseUrl != null &&
            username != null &&
            password != null) {
          emit(
            LoginWebDAV(
              server: server,
              baseUrl: baseUrl,
              username: username,
              password: password,
            ),
          );
        }
      }
    } on Exception catch (e) {
      emit(LoginError(message: e.toString()));
    }
  }

  void loginError(String message) {
    emit(LoginError(message: message));
  }

  Future<void> logout() async {
    try {
      await resetSecureStorage();
      emit(const Logout());
    } on Exception catch (e) {
      emit(LoginError(message: e.toString()));
    }
  }

  Future<void> loginOffline({
    required todoFile,
  }) async {
    try {
      await resetSecureStorage();
      await secureStorage.write(key: 'backend', value: Backend.offline.name);
      LocalTodoListApi(todoFile: todoFile); // Check before login.
      emit(const LoginOffline());
    } on Exception catch (e) {
      emit(LoginError(message: e.toString()));
    }
  }

  Future<void> loginWebDAV({
    required File todoFile,
    required String server,
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    try {
      await resetSecureStorage();
      await secureStorage.write(key: 'backend', value: Backend.webdav.name);
      await secureStorage.write(key: 'server', value: server);
      await secureStorage.write(key: 'baseUrl', value: baseUrl);
      await secureStorage.write(key: 'username', value: username);
      await secureStorage.write(key: 'password', value: password);
      // Check before login.
      WebDAVTodoListApi api = WebDAVTodoListApi(
        todoFile: todoFile,
        server: server,
        baseUrl: baseUrl,
        username: username,
        password: password,
      );
      await api.client.ping();
      emit(
        LoginWebDAV(
          server: server,
          baseUrl: baseUrl,
          username: username,
          password: password,
        ),
      );
    } on Exception catch (e) {
      emit(LoginError(message: e.toString()));
    }
  }

  Future<void> resetSecureStorage() async {
    try {
      final List<String> attrs = [
        'backend',
        'server',
        'baseUrl',
        'username',
        'password',
      ];
      for (var attr in attrs) {
        await secureStorage.delete(key: attr);
      }
      emit(const Logout());
    } on Exception catch (e) {
      emit(LoginError(message: e.toString()));
    }
  }
}
