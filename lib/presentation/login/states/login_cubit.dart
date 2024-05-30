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
      emit(state.loading());
      String? backendFromsecureStorage =
          await secureStorage.read(key: 'backend');
      Backend backend;

      if (backendFromsecureStorage == null) {
        return emit(state.logout());
      }

      try {
        backend = Backend.values.byName(backendFromsecureStorage);
      } on Exception {
        return emit(state.logout());
      }

      if (backend == Backend.none) {
        return emit(state.logout());
      }

      // @todo: Keep 'offline' for backward compatibility.
      if (backend == Backend.local || backend == Backend.offline) {
        // @todo: Remove with the next releases.
        await secureStorage.write(key: 'backend', value: Backend.local.name);
        return emit(state.loginLocal());
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
            state.loginWebDAV(
              server: server,
              baseUrl: baseUrl,
              username: username,
              password: password,
            ),
          );
        }
      }
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await resetSecureStorage();
      emit(state.logout());
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> loginLocal({
    required File localTodoFile,
  }) async {
    try {
      LocalTodoListApi(localTodoFile: localTodoFile); // Check before login.
      await resetSecureStorage();
      await secureStorage.write(key: 'backend', value: Backend.local.name);
      emit(state.loginLocal());
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> loginWebDAV({
    required File localTodoFile,
    required String remoteTodoFile,
    required String server,
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    try {
      // Check before login.
      WebDAVTodoListApi api = WebDAVTodoListApi(
        localTodoFile: localTodoFile,
        remoteTodoFile: remoteTodoFile,
        server: server,
        baseUrl: baseUrl,
        username: username,
        password: password,
      );
      await api.client.ping();
      await api.client.listFiles();
      await resetSecureStorage();
      await secureStorage.write(key: 'backend', value: Backend.webdav.name);
      await secureStorage.write(key: 'server', value: server);
      await secureStorage.write(key: 'baseUrl', value: baseUrl);
      await secureStorage.write(key: 'username', value: username);
      await secureStorage.write(key: 'password', value: password);
      emit(
        state.loginWebDAV(
          server: server,
          baseUrl: baseUrl,
          username: username,
          password: password,
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
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
        final String? value = await secureStorage.read(key: attr);
        if (value != null) {
          await secureStorage.delete(key: attr);
        }
      }
      emit(state.logout());
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }
}
