import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ntodotxt/presentation/login/states/login_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FlutterSecureStorage storage;

  AuthCubit({
    required this.storage,
    // Pass initial state ti prevent screen flicker in start.
    required AuthState state,
  }) : super(state);

  // To detect the initial authentication state before initializing the cubit.
  static Future<AuthState> init(FlutterSecureStorage storage) async {
    String? backendFromStorage = await storage.read(key: 'backend');
    Backend backend;

    if (backendFromStorage == null) {
      return const Unauthenticated();
    }

    try {
      backend = Backend.values.byName(backendFromStorage);
    } on Exception {
      return const Unauthenticated();
    }

    if (backend == Backend.offline) {
      return const OfflineLogin();
    }
    if (backend == Backend.webdav) {
      String? server = await storage.read(key: 'server');
      String? username = await storage.read(key: 'username');
      String? password = await storage.read(key: 'password');
      if (server != null && username != null && password != null) {
        return WebDAVLogin(
          server: server,
          username: username,
          password: password,
        );
      }
    }

    return const Unauthenticated();
  }

  Future<void> resetSecureStorage() async {
    final List<String> attrs = [
      'backend',
      'server',
      'username',
      'password',
    ];
    for (var attr in attrs) {
      await storage.delete(key: attr);
    }
  }

  Future<void> loginOffline() async {
    await resetSecureStorage();
    await storage.write(key: 'backend', value: Backend.offline.name);
    emit(const OfflineLogin());
  }

  Future<void> logout() async {
    await resetSecureStorage();
    emit(const Unauthenticated());
  }

  Future<void> loginWebDAV({
    required String server,
    required String username,
    required String password,
  }) async {
    await resetSecureStorage();
    await storage.write(key: 'backend', value: Backend.webdav.name);
    await storage.write(key: 'server', value: server);
    await storage.write(key: 'username', value: username);
    await storage.write(key: 'password', value: password);
    emit(
      WebDAVLogin(
        server: server,
        username: username,
        password: password,
      ),
    );
  }

  Future<void> updateWebDAVServer(String? value) async {
    if (state is! WebDAVLogin) {
      return;
    }
    if (value != null) {
      if (value.isNotEmpty) {
        await storage.write(key: 'server', value: value);
        emit((state as WebDAVLogin).copyWith(server: value));
      }
    }
  }

  Future<void> updateWebDAVUsername(String? value) async {
    if (state is! WebDAVLogin) {
      return;
    }
    if (value != null) {
      if (value.isNotEmpty) {
        await storage.write(key: 'username', value: value);
        emit((state as WebDAVLogin).copyWith(username: value));
      }
    }
  }

  Future<void> updateWebDAVPassword(String? value) async {
    if (state is! WebDAVLogin) {
      return;
    }
    if (value != null) {
      if (value.isNotEmpty) {
        await storage.write(key: 'password', value: value);
        emit((state as WebDAVLogin).copyWith(password: value));
      }
    }
  }

  Future<void> updateBackend(Backend? value) async {
    if (value != null) {
      if (value == Backend.offline) {
        await storage.write(key: 'backend', value: Backend.offline.name);
        emit(const OfflineLogin());
      } else if (value == Backend.webdav) {
        await storage.write(key: 'backend', value: Backend.webdav.name);
        emit(
          const WebDAVLogin(
            server: '',
            username: '',
            password: '',
          ),
        );
      } else {
        emit(const Unauthenticated());
      }
    }
  }
}
