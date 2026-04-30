import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/tournament_invitation.dart';
import 'package:tennis_cup/ui/user/player/view_models/invitations_cubit.dart';

final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
final DateFormat _timeFormatter = DateFormat('HH:mm');

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tournament = invitation.tournament;
    final arenaSubtitle = tournament.arena.city == null
        ? tournament.arena.title
        : '${tournament.arena.title} · ${tournament.arena.city}';

    final cubit = context.read<InvitationsCubit>();
    final accepted = invitation.status == InvitationStatus.accepted;
    final declined = invitation.status == InvitationStatus.declined;
    final decided = accepted || declined;

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
                    arenaSubtitle,
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _dateFormatter.format(tournament.date),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRow(context, 'Start time',
                _timeFormatter.format(invitation.startTime)),
            _buildRow(context, 'End time',
                _timeFormatter.format(invitation.endTime)),
            _buildRow(
                context, 'Player number', invitation.playerNumber.toString()),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed:
                        decided ? null : () => cubit.accept(invitation.id),
                    icon: Icon(accepted ? Icons.check_circle : Icons.check),
                    label: Text(accepted ? 'Accepted' : 'Accept'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        decided ? null : () => cubit.decline(invitation.id),
                    icon: Icon(declined ? Icons.cancel : Icons.close),
                    label: Text(declined ? 'Declined' : 'Decline'),
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
