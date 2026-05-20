import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/auth/view_models/auth_cubit.dart';
import 'package:tennis_cup/ui/core/widgets/user_registration_form_body.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/user_edit_cubit.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/avatar_section.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/user_roles_section.dart';

class EditUserScreen extends StatelessWidget {
  final int userId;

  const EditUserScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserEditCubit(
        playerRepository: ServiceLocator.playerRepository,
      )..loadUser(userId),
      child: Builder(
        builder: (context) => BlocListener<UserEditCubit, UserEditState>(
          listener: (context, state) {
            if (state is UserEditSuccess) {
              Navigator.of(context).pop();
            } else if (state is UserEditError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ));
            }
          },
          child: Scaffold(
            appBar: AppBar(title: Text(S.of(context).editUser)),
            body: BlocBuilder<UserEditCubit, UserEditState>(
              builder: (context, state) {
                if (state is UserEditInitial || state is UserEditLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is! UserEditLoaded) return const SizedBox.shrink();

                final user = state.user;
                final manageableRoles = _manageableRoles(context);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AvatarSection(state: state),
                      if (manageableRoles.isNotEmpty)
                        UserRolesSection(
                          state: state,
                          manageableRoles: manageableRoles,
                        ),
                      UserRegistrationFormBody(
                        isLoading: state.saving,
                        submitLabel: S.of(context).save,
                        currentStatus: state.user.status,
                        initialValues: UserProfileInitialValues(
                          firstName: user.firstName,
                          lastName: user.lastName,
                          patronymicName: user.patronymicName.isEmpty
                              ? null
                              : user.patronymicName,
                          birthDate: user.birthDate,
                          gender: user.genderString,
                          country: user.country.isEmpty ? null : user.country,
                          city: user.city.isEmpty ? null : user.city,
                        ),
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
                          context.read<UserEditCubit>().saveUser(userId, {
                            'firstName': firstName,
                            'lastName': lastName,
                            if (patronymicName != null)
                              'patronymicName': patronymicName,
                            'birthDate': birthDate,
                            'gender': gender,
                            'country': country,
                            'city': city,
                            if (status != null) 'status': status,
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<UserRole> _manageableRoles(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return [];
    if (authState.roles.contains(UserRole.admin)) {
      return [
        UserRole.player,
        UserRole.referee,
        UserRole.organizer,
        UserRole.admin,
      ];
    }
    if (authState.roles.contains(UserRole.organizer)) {
      return [UserRole.player, UserRole.referee];
    }
    return [];
  }
}
