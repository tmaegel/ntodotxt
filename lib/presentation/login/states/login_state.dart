import 'package:equatable/equatable.dart';

enum Backend { none, offline, webdav }

sealed class LoginState extends Equatable {
  /// Backend to use to store todos.
  final Backend backend;

  const LoginState({
    this.backend = Backend.none,
  });

  LoginState copyWith();

  @override
  List<Object> get props => [
        backend,
      ];

  @override
  String toString() => 'LoginState { }';
}

final class LoginWebDAV extends LoginState {
  /// Backend server.
  final String server;

  /// Base Url.
  final String baseUrl;

  /// Backend username.
  final String username;

  /// Backend password.
  final String password;

  const LoginWebDAV({
    super.backend = Backend.webdav,
    required this.server,
    required this.baseUrl,
    required this.username,
    required this.password,
  });

  @override
  LoginWebDAV copyWith({
    String? server,
    String? baseUrl,
    String? username,
    String? password,
  }) {
    return LoginWebDAV(
      server: server ?? this.server,
      baseUrl: baseUrl ?? this.baseUrl,
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
  String toString() => 'LoginWebDAV { }';
}

final class LoginOffline extends LoginState {
  const LoginOffline({
    super.backend = Backend.offline,
  });

  @override
  LoginOffline copyWith() {
    return const LoginOffline();
  }

  @override
  List<Object> get props => [
        backend,
      ];

  @override
  String toString() => 'LoginOffline { }';
}

final class LoginError extends LoginState {
  /// Error message.
  final String message;

  const LoginError({
    required this.message,
    super.backend,
  });

  @override
  LoginError copyWith({
    String? message,
  }) {
    return LoginError(
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [
        backend,
      ];

  @override
  String toString() => 'LoginError { message: $message }';
}

final class Logout extends LoginState {
  const Logout({
    super.backend,
  });

  @override
  Logout copyWith() {
    return const Logout();
  }

  @override
  List<Object> get props => [
        backend,
      ];

  @override
  String toString() => 'Logout { }';
}
