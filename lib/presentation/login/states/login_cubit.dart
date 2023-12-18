import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/main.dart' show secureStorage;
import 'package:ntodotxt/presentation/login/states/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    // Pass initial state to prevent screen flicker in start.
    required LoginState state,
  }) : super(state);

  Future<void> resetSecureStorage() async {
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

  Future<void> loginOffline() async {
    try {
      await resetSecureStorage();
      await secureStorage.write(key: 'backend', value: Backend.offline.name);
      emit(const LoginOffline());
    } on Exception catch (e) {
      emit(LoginError(message: e.toString()));
    }
  }

  Future<void> loginWebDAV({
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
}
