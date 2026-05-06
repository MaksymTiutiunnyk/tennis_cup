import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/ui/user/core/view_models/active_role_cubit.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/user_creation_cubit.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/user_creation_state.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/create_organizer_form.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/create_player_form.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/create_referee_form.dart';

class CreateUserFab extends StatelessWidget {
  const CreateUserFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showRoleSheet(context),
      child: const Icon(Icons.person_add),
    );
  }

  void _showRoleSheet(BuildContext context) {
    final isAdmin = context
        .read<ActiveRoleCubit>()
        .state
        .activeRole == UserRole.admin;

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Add user',
                style: Theme.of(sheetCtx).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sports_tennis),
              title: const Text('Register Player'),
              subtitle: const Text('Creates a pending-approval account'),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _showForm(context, const CreatePlayerForm(), 'Register Player');
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_outlined),
              title: const Text('Register Referee'),
              subtitle: const Text('Creates a pending-approval account'),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _showForm(context, const CreateRefereeForm(), 'Register Referee');
              },
            ),
            if (isAdmin)
              ListTile(
                leading: const Icon(Icons.manage_accounts),
                title: const Text('Create Organizer'),
                subtitle: const Text('Creates an active account immediately'),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _showForm(context, const CreateOrganizerForm(), 'Create Organizer');
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showForm(BuildContext context, Widget form, String title) {
    final cubit = context.read<UserCreationCubit>();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => BlocProvider.value(
        value: cubit,
        child: BlocListener<UserCreationCubit, UserCreationState>(
          listener: (ctx, state) {
            if (state is UserCreationSuccess || state is UserCreationError) {
              Navigator.of(dialogCtx).pop();
            }
          },
          child: AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(child: form),
          ),
        ),
      ),
    );
  }
}
