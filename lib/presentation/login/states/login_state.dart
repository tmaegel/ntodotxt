import 'package:equatable/equatable.dart';

enum Backend { offline, webdav }

sealed class AuthState extends Equatable {
  /// Backend to use to store todos.
  final Backend backend;

  const AuthState({
    this.backend = Backend.offline,
  });

  AuthState copyWith();

  @override
  List<Object> get props => [
        backend,
      ];

  @override
  String toString() => 'AuthState { }';
}

final class WebDAVLogin extends AuthState {
  /// Backend server.
  final String server;

  /// Backend username.
  final String username;

  /// Backend password.
  final String password;

  const WebDAVLogin({
    super.backend = Backend.webdav,
    required this.server,
    required this.username,
    required this.password,
  });

  @override
  WebDAVLogin copyWith({
    String? server,
    String? username,
    String? password,
  }) {
    return WebDAVLogin(
      server: server ?? this.server,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  @override
  List<Object> get props => [
        backend,
        server,
        username,
        password,
      ];

  @override
  String toString() => 'WebDAVLogin { }';
}

final class OfflineLogin extends AuthState {
  const OfflineLogin({
    super.backend,
  });

  @override
  OfflineLogin copyWith() {
    return const OfflineLogin();
  }

  @override
  List<Object> get props => [
        backend,
      ];

  @override
  String toString() => 'OfflineLogin { }';
}

final class Unauthenticated extends AuthState {
  const Unauthenticated({
    super.backend,
  });

  @override
  Unauthenticated copyWith() {
    return const Unauthenticated();
  }

  @override
  List<Object> get props => [
        backend,
      ];

  @override
  String toString() => 'Unauthenticated { }';
}
