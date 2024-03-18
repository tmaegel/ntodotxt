import 'package:equatable/equatable.dart';

// @todo: Keep 'offline' for backward compatibility.
enum Backend { none, local, offline, webdav }

sealed class LoginState extends Equatable {
  final Backend backend; // Backend to use to store todos.

  const LoginState({
    this.backend = Backend.none,
  });

  LoginState copyWith();

  LoginLoading loading() => const LoginLoading();

  Logout logout() => const Logout();

  LoginLocal loginLocal() => const LoginLocal();

  LoginWebDAV loginWebDAV({
    required String server,
    required String baseUrl,
    required String username,
    required String password,
  }) =>
      LoginWebDAV(
        server: server,
        baseUrl: baseUrl,
        username: username,
        password: password,
      );

  LoginError error({
    required String message,
  }) =>
      LoginError(message: message);

  @override
  List<Object> get props => [
        backend,
      ];

  @override
  String toString() => 'LoginState { }';
}

final class LoginLoading extends LoginState {
  const LoginLoading({
    super.backend,
  });

  @override
  LoginLoading copyWith() => super.loading();

  @override
  List<Object> get props => [
        backend,
      ];

  @override
  String toString() => 'LoginLoading { }';
}

final class Logout extends LoginState {
  const Logout({
    super.backend = Backend.none,
  });

  @override
  Logout copyWith() => super.logout();

  @override
  List<Object> get props => [
        backend,
      ];

  @override
  String toString() => 'Logout { }';
}

final class LoginLocal extends LoginState {
  const LoginLocal({
    super.backend = Backend.local,
  });

  @override
  LoginLocal copyWith() => super.loginLocal();

  @override
  List<Object> get props => [
        backend,
      ];

  @override
  String toString() => 'LoginLocal { }';
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
  }) =>
      super.loginWebDAV(
        server: server ?? this.server,
        baseUrl: baseUrl ?? this.baseUrl,
        username: username ?? this.username,
        password: password ?? this.password,
      );

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
  }) =>
      super.error(message: message ?? this.message);

  @override
  List<Object> get props => [
        backend,
      ];

  @override
  String toString() => 'LoginError { message: $message }';
}
