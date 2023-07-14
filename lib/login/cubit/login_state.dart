import 'package:equatable/equatable.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class LoginState extends Equatable {
  final AuthStatus status;

  const LoginState._({this.status = AuthStatus.unknown});

  const LoginState.authenticated() : this._(status: AuthStatus.authenticated);

  const LoginState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  @override
  List<Object> get props => [status];

  @override
  String toString() => 'LoginState { status: $status }';
}
