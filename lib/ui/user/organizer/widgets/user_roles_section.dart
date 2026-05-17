import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/user_edit_cubit.dart';

class UserRolesSection extends StatelessWidget {
  final UserEditLoaded state;
  final List<UserRole> manageableRoles;

  const UserRolesSection({
    super.key,
    required this.state,
    required this.manageableRoles,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cubit = context.read<UserEditCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.roles, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: manageableRoles.map((role) {
            return FilterChip(
              label: Text(_roleLabel(role, s)),
              selected: state.roles.contains(role),
              onSelected: state.saving ? null : (_) => cubit.toggleRole(role),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _roleLabel(UserRole role, S s) => switch (role) {
        UserRole.player => s.rolePlayer,
        UserRole.referee => s.roleReferee,
        UserRole.organizer => s.roleOrganizer,
        UserRole.admin => s.roleAdmin,
      };
}
