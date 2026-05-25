import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/gender.dart';
import 'package:tennis_cup/data/models/tournament_invitation.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/user/player/view_models/invitations_cubit.dart';

final DateFormat _dateFmt = DateFormat('dd MMM yyyy');
final DateFormat _timeFmt = DateFormat('HH:mm');

class TournamentInvitationCard extends StatelessWidget {
  final TournamentInvitation invitation;

  const TournamentInvitationCard({super.key, required this.invitation});

  Widget _buildRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Future<bool> _confirm(
      BuildContext context, String title, String action) async {
    final s = S.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: Text(s.cannotBeUndone),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(s.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final tournament = invitation.tournament;
    final arenaSubtitle = tournament.arena.city == null
        ? tournament.arena.title
        : '${tournament.arena.title} · ${tournament.arena.city}';
    final isReferee = invitation.role == InvitationRole.referee;

    final cubit = context.read<InvitationsCubit>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tournament.name.isNotEmpty
                        ? tournament.name
                        : arenaSubtitle,
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(
                    isReferee ? s.roleReferee : s.rolePlayer,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isReferee
                          ? theme.colorScheme.onTertiary
                          : theme.colorScheme.onSecondary,
                    ),
                  ),
                  backgroundColor: isReferee
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.secondary,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRow(context, s.arenaField, arenaSubtitle),
            _buildRow(context, s.labelDate, _dateFmt.format(tournament.date)),
            _buildRow(context, s.labelStart, _timeFmt.format(tournament.date)),
            if (tournament.gender.isNotEmpty)
              _buildRow(
                  context,
                  s.genderField,
                  tournament.gender.toLowerCase() == Gender.male.name
                      ? s.menLabel
                      : s.womenLabel),
            _buildRow(
              context,
              s.playersLabel,
              tournament.requiredPlayersCount?.toString() ?? '–',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      final ok = await _confirm(
                          context, s.acceptInvitationTitle, s.accept);
                      if (ok && context.mounted) {
                        cubit.accept(invitation.id);
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: Text(s.accept),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final ok = await _confirm(
                          context, s.declineInvitationTitle, s.decline);
                      if (ok && context.mounted) {
                        cubit.decline(invitation.id);
                      }
                    },
                    icon: const Icon(Icons.close),
                    label: Text(s.decline),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
