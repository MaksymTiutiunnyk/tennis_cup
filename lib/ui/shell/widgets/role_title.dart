import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/user/core/view_models/active_role_cubit.dart';

class RoleTitle extends StatelessWidget {
  final ActiveRoleState roleState;

  const RoleTitle({super.key, required this.roleState});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    if (roleState.availableRoles.length < 2) {
      return Text(_roleName(roleState.activeRole, s));
    }
    return DropdownButton<UserRole>(
      value: roleState.activeRole,
      underline: const SizedBox.shrink(),
      items: roleState.availableRoles
          .map((role) => DropdownMenuItem(
                value: role,
                child: Text(
                  _roleName(role, s),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey),
                ),
              ))
          .toList(),
      onChanged: (newRole) {
        if (newRole == null) return;
        context.read<ActiveRoleCubit>().switchRole(newRole);
      },
    );
  }

  String _roleName(UserRole role, S s) => switch (role) {
        UserRole.player => s.rolePlayer,
        UserRole.referee => s.roleReferee,
        UserRole.organizer => s.roleOrganizer,
        UserRole.admin => s.roleAdmin,
      };
}
