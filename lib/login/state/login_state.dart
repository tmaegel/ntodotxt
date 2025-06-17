import 'dart:math';

import 'package:equatable/equatable.dart';

enum Backend { none, local, webdav }

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
    required String path,
    required String username,
    required String password,
    required bool acceptUntrustedCert,
  }) =>
      LoginWebDAV(
        server: server,
        path: path,
        username: username,
        password: password,
        acceptUntrustedCert: acceptUntrustedCert,
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

  /// Path.
  final String path;

  /// Backend username.
  final String username;

  /// Backend password.
  final String password;

  /// Accept untrusted certificate.
  final bool acceptUntrustedCert;

  const LoginWebDAV({
    super.backend = Backend.webdav,
    required this.server,
    required this.path,
    required this.username,
    required this.password,
    required this.acceptUntrustedCert,
  });

  @override
  LoginWebDAV copyWith({
    String? server,
    String? path,
    String? username,
    String? password,
    bool? acceptUntrustedCert,
  }) =>
      super.loginWebDAV(
        server: server ?? this.server,
        path: path ?? this.path,
        username: username ?? this.username,
        password: password ?? this.password,
        acceptUntrustedCert: acceptUntrustedCert ?? this.acceptUntrustedCert,
      );

  @override
  List<Object> get props => [
        backend,
        server,
        path,
        username,
        password,
        acceptUntrustedCert,
      ];

  @override
  String toString() => 'LoginWebDAV { }';
}

final class LoginError extends LoginState {
  /// Random id to force updates/rebuilds
  /// if there occure the same errors in row.
  final int id;

  /// Error message.
  final String message;

  LoginError({
    required this.message,
    super.backend,
  }) : id = Random().nextInt(999);

  @override
  LoginError copyWith({
    String? message,
  }) =>
      super.error(message: message ?? this.message);

  @override
  List<Object> get props => [
        id,
        backend,
        message,
      ];

  @override
  String toString() => 'LoginError { message: $message }';
}
