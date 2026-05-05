import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/ui/user/core/view_models/active_role_cubit.dart';

class RoleTitle extends StatelessWidget {
  final ActiveRoleState roleState;

  const RoleTitle({super.key, required this.roleState});

  @override
  Widget build(BuildContext context) {
    if (roleState.availableRoles.length < 2) {
      return Text(_roleName(roleState.activeRole));
    }
    return DropdownButton<UserRole>(
      value: roleState.activeRole,
      underline: const SizedBox.shrink(),
      items: roleState.availableRoles
          .map((role) => DropdownMenuItem(
                value: role,
                child: Text(
                  _roleName(role),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ))
          .toList(),
      onChanged: (newRole) {
        if (newRole == null) return;
        context.read<ActiveRoleCubit>().switchRole(newRole);
      },
    );
  }

  String _roleName(UserRole role) => switch (role) {
        UserRole.player => 'Player',
        UserRole.referee => 'Referee',
        UserRole.organizer => 'Organizer',
        UserRole.admin => 'Admin',
      };
}
