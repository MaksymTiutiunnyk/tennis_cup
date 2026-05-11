import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/ui/auth/view_models/auth_cubit.dart';
import 'package:tennis_cup/ui/core/widgets/user_registration_form_body.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/user_creation_cubit.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/user_creation_state.dart';

class CreateUserScreen extends StatelessWidget {
  const CreateUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final isAdmin = authState is AuthAuthenticated &&
        authState.roles.contains(UserRole.admin);
    final availableRoles = [
      'PLAYER',
      'REFEREE',
      if (isAdmin) ...['ORGANIZER', 'ADMIN'],
    ];

    return BlocProvider(
      create: (_) =>
          UserCreationCubit(adminRepository: ServiceLocator.adminRepository),
      child: Builder(
        builder: (context) =>
            BlocListener<UserCreationCubit, UserCreationState>(
          listener: (context, state) {
            if (state is UserCreationSuccess) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is UserCreationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: Scaffold(
            appBar: AppBar(title: const Text('Add user')),
            body: BlocBuilder<UserCreationCubit, UserCreationState>(
              builder: (context, state) => SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: UserRegistrationFormBody(
                  availableRoles: availableRoles,
                  isLoading: state is UserCreationLoading,
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
                    context.read<UserCreationCubit>().createUser(
                          role: role!,
                          login: login!,
                          password: password!,
                          firstName: firstName,
                          lastName: lastName,
                          patronymicName: patronymicName,
                          birthDate: birthDate,
                          gender: gender,
                          country: country,
                          city: city,
                        );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
