import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/user_role.dart';

class RoleChip extends StatelessWidget {
  final UserRole role;

  const RoleChip({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(_label(role), style: const TextStyle(fontSize: 11)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  String _label(UserRole role) => switch (role) {
        UserRole.player => 'Player',
        UserRole.referee => 'Referee',
        UserRole.organizer => 'Organizer',
        UserRole.admin => 'Admin',
      };
}
