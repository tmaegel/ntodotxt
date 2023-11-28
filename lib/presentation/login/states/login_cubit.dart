import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ntodotxt/presentation/login/states/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final FlutterSecureStorage storage;

  LoginCubit({
    required this.storage,
    // Pass initial state ti prevent screen flicker in start.
    required LoginState state,
  }) : super(state);

  // To detect the initial authentication state before initializing the cubit.
  static Future<LoginState> init(FlutterSecureStorage storage) async {
    String? backendFromStorage = await storage.read(key: 'backend');
    Backend backend;

    if (backendFromStorage == null) {
      return const Logout();
    }

    try {
      backend = Backend.values.byName(backendFromStorage);
    } on Exception {
      return const Logout();
    }

    if (backend == Backend.none) {
      return const Logout();
    }
    if (backend == Backend.offline) {
      return const LoginOffline();
    }
    if (backend == Backend.webdav) {
      String? server = await storage.read(key: 'server');
      String? baseUrl = await storage.read(key: 'baseUrl');
      String? username = await storage.read(key: 'username');
      String? password = await storage.read(key: 'password');
      if (server != null &&
          baseUrl != null &&
          username != null &&
          password != null) {
        return LoginWebDAV(
          server: server,
          baseUrl: baseUrl,
          username: username,
          password: password,
        );
      }
    }

    return const Logout();
  }

  Future<void> resetSecureStorage() async {
    final List<String> attrs = [
      'backend',
      'server',
      'baseUrl',
      'username',
      'password',
    ];
    for (var attr in attrs) {
      await storage.delete(key: attr);
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
      await storage.write(key: 'backend', value: Backend.offline.name);
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
      await storage.write(key: 'backend', value: Backend.webdav.name);
      await storage.write(key: 'server', value: server);
      await storage.write(key: 'baseUrl', value: baseUrl);
      await storage.write(key: 'username', value: username);
      await storage.write(key: 'password', value: password);
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
