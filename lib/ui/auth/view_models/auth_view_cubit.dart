import 'package:flutter_bloc/flutter_bloc.dart';

enum AuthView { login, register }

class AuthViewCubit extends Cubit<AuthView> {
  AuthViewCubit() : super(AuthView.login);

  void showLogin() => emit(AuthView.login);
  void showRegister() => emit(AuthView.register);
}
