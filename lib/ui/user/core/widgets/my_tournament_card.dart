import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/gender.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/models/tournament_invitation.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/routing/app_router.dart';

final DateFormat _dateFmt = DateFormat('dd MMM yyyy');
final DateFormat _timeFmt = DateFormat('HH:mm');

class MyTournamentCard extends StatelessWidget {
  final Tournament tournament;
  final InvitationRole role;

  const MyTournamentCard({
    super.key,
    required this.tournament,
    required this.role,
  });

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

  VoidCallback? _onTap(BuildContext context) {
    final id = tournament.tournamentId;
    if (role == InvitationRole.player) {
      return () => context.push(
            AppRoutes.tournamentSchedulePreview(id),
            extra: tournament.name,
          );
    }
    if (tournament.status == TournamentStatus.active) {
      return () => context.push(
            AppRoutes.tournamentManage(id),
            extra: tournament.name,
          );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final arenaSubtitle = tournament.arena.city == null
        ? tournament.arena.title
        : '${tournament.arena.title} · ${tournament.arena.city}';
    final isActive = tournament.status == TournamentStatus.active;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _onTap(context),
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
                      isActive
                          ? s.tournamentStatusActive
                          : s.tournamentStatusPending,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isActive
                            ? theme.colorScheme.onTertiary
                            : theme.colorScheme.onSecondary,
                      ),
                    ),
                    backgroundColor: isActive
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
              _buildRow(
                  context, s.labelStart, _timeFmt.format(tournament.date)),
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
            ],
          ),
        ),
      ),
    );
  }
}
