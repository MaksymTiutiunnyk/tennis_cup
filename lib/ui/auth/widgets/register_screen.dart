import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/auth/view_models/auth_cubit.dart';
import 'package:tennis_cup/ui/auth/view_models/auth_view_cubit.dart';
import 'package:tennis_cup/ui/core/widgets/user_registration_form_body.dart';

class RegisterContent extends StatelessWidget {
  const RegisterContent({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).registrationSubmitted)),
          );
          context.read<AuthViewCubit>().showLogin();
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                s.createAccount,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              UserRegistrationFormBody(
                availableRoles: const ['PLAYER', 'REFEREE'],
                isLoading: state is AuthLoading,
                submitLabel: s.register,
                onSubmit: ({
                  role,
                  login,
                  password,
                  required firstName,
                  required lastName,
                  patronymicName,
                  required birthDate,
                  required gender,
                  required country,
                  required city,
                  String? status,
                }) {
                  context.read<AuthCubit>().register(
                        login: login!,
                        password: password!,
                        role: role!,
                        firstName: firstName,
                        lastName: lastName,
                        patronymicName: patronymicName,
                        birthDate: birthDate,
                        gender: gender,
                        country: country,
                        city: city,
                      );
                },
                footer: TextButton(
                  onPressed: context.read<AuthViewCubit>().showLogin,
                  child: Text(s.alreadyHaveAccount),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
