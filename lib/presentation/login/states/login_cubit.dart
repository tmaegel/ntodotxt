import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/login/states/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState.unauthenticated());

  void login() {
    emit(const LoginState.authenticated());
  }

  void logout() {
    emit(const LoginState.unauthenticated());
  }
}
