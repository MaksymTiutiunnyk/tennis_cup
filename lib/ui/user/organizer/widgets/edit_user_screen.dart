import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/ui/core/widgets/user_registration_form_body.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/user_edit_cubit.dart';

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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: Scaffold(
            appBar: AppBar(title: const Text('Edit user')),
            body: BlocBuilder<UserEditCubit, UserEditState>(
              builder: (context, state) {
                if (state is UserEditInitial || state is UserEditLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is! UserEditLoaded) return const SizedBox.shrink();

                final user = state.user;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: UserRegistrationFormBody(
                    isLoading: state.saving,
                    submitLabel: 'Save',
                    initialValues: UserProfileInitialValues(
                      firstName: user.name,
                      lastName: user.surname,
                      patronymicName: user.patronymicName.isEmpty
                          ? null
                          : user.patronymicName,
                      birthDate: user.birthDate,
                      gender: user.genderString,
                      country: user.country.isEmpty ? null : user.country,
                      city: user.city.isEmpty ? null : user.city,
                    ),
                    onAvatarUpload: () =>
                        context.read<UserEditCubit>().uploadAvatar(userId),
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
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
