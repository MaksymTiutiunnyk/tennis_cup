import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/pending_user.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/pending_users_cubit.dart';

final _dateFmt = DateFormat('dd MMM yyyy');

class PendingUserCard extends StatelessWidget {
  final PendingUser user;

  const PendingUserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cubit = context.read<PendingUsersCubit>();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    user.login,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  _dateFmt.format(user.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: user.roles
                  .map((r) => Chip(
                        label: Text(_roleName(r, s),
                            style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () => _confirmReject(context, cubit),
                  child: Text(s.reject),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => cubit.approve(user.id),
                  child: Text(s.approve),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReject(BuildContext context, PendingUsersCubit cubit) {
    final s = S.of(context);
    var reason = '';
    showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(s.rejectRegistration),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${s.reject} "${user.login}"?'),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: s.reasonOptional),
              onChanged: (v) => reason = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(s.reject),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        final trimmed = reason.trim();
        cubit.reject(user.id, reason: trimmed.isEmpty ? null : trimmed);
      }
    });
  }

  String _roleName(UserRole role, S s) => switch (role) {
        UserRole.player => s.rolePlayer,
        UserRole.referee => s.roleReferee,
        UserRole.organizer => s.roleOrganizer,
        UserRole.admin => s.roleAdmin,
      };
}
