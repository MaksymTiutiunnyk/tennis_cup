import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/generated/l10n.dart';

class RoleChip extends StatelessWidget {
  final UserRole role;

  const RoleChip({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Chip(
      label: Text(_label(role, s), style: const TextStyle(fontSize: 11)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  String _label(UserRole role, S s) => switch (role) {
        UserRole.player => s.rolePlayer,
        UserRole.referee => s.roleReferee,
        UserRole.organizer => s.roleOrganizer,
        UserRole.admin => s.roleAdmin,
      };
}
