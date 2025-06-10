import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/client/webdav_client.dart';
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

      if (backend == Backend.local) {
        return emit(state.loginLocal());
      }
      if (backend == Backend.webdav) {
        String? server = await secureStorage.read(key: 'server');
        String? path = await secureStorage.read(key: 'path');
        String? username = await secureStorage.read(key: 'username');
        String? password = await secureStorage.read(key: 'password');
        bool acceptUntrustedCert =
            (await secureStorage.read(key: 'acceptUntrustedCert')) == '1'
                ? true
                : false;
        if (server != null &&
            path != null &&
            username != null &&
            password != null) {
          emit(
            state.loginWebDAV(
              server: server,
              path: path,
              username: username,
              password: password,
              acceptUntrustedCert: acceptUntrustedCert,
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
    required String localTodoFilePath,
  }) async {
    try {
      LocalTodoListApi.fromString(
          localFilePath: localTodoFilePath); // Check before login.
      await resetSecureStorage();
      await secureStorage.write(key: 'backend', value: Backend.local.name);
      emit(state.loginLocal());
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> loginWebDAV({
    required String localTodoFilePath,
    required String remoteTodoFilePath,
    required String server,
    required String path,
    required String username,
    required String password,
    required bool acceptUntrustedCert,
  }) async {
    try {
      WebDAVClient client = WebDAVClient(
        server: server,
        path: path,
        username: username,
        password: password,
        acceptUntrustedCert: acceptUntrustedCert,
      );
      WebDAVTodoListApi api = WebDAVTodoListApi.fromString(
        localFilePath: localTodoFilePath,
        remoteFilePath: remoteTodoFilePath,
        client: client,
      );
      await api.client.ping();
      await api.client.listFiles();
      await resetSecureStorage();
      await secureStorage.write(key: 'backend', value: Backend.webdav.name);
      await secureStorage.write(key: 'server', value: server);
      await secureStorage.write(key: 'path', value: path);
      await secureStorage.write(key: 'username', value: username);
      await secureStorage.write(key: 'password', value: password);
      await secureStorage.write(
          key: 'acceptUntrustedCert', value: acceptUntrustedCert ? '1' : '0');
      emit(
        state.loginWebDAV(
          server: server,
          path: path,
          username: username,
          password: password,
          acceptUntrustedCert: acceptUntrustedCert,
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
        'path',
        'username',
        'password',
        'acceptUntrustedCert',
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
