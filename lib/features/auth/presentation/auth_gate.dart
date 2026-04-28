import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/features/auth/logic/auth_view_cubit.dart';
import 'package:tennis_cup/features/auth/presentation/login_screen.dart';
import 'package:tennis_cup/features/auth/presentation/register_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthViewCubit(),
      child: BlocBuilder<AuthViewCubit, AuthView>(
        builder: (context, view) {
          if (view == AuthView.login) {
            return const LoginContent();
          }
          return const RegisterContent();
        },
      ),
    );
  }
}
