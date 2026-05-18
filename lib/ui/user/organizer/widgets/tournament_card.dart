import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/gender.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/organizer_tournaments_cubit.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/tournament_form.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/tournament_status_chip.dart';

final _dateFmt = DateFormat('dd MMM yyyy HH:mm');

class TournamentCard extends StatelessWidget {
  final Tournament tournament;

  const TournamentCard({super.key, required this.tournament});

  bool get canBeStarted {
    return tournament.status == TournamentStatus.pending &&
        tournament.refereeId != null &&
        tournament.players.length == tournament.requiredPlayersCount;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cubit = context.read<OrganizerTournamentsCubit>();
    final theme = Theme.of(context);
    final tournamentGender = tournament.gender.toLowerCase() == Gender.male.name
        ? s.menLabel
        : s.womenLabel;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(tournament.name, style: theme.textTheme.titleMedium),
        subtitle: Text(
          '$tournamentGender · ${tournament.arena.title} · '
          '${s.playersCountLabel(tournament.requiredPlayersCount ?? 0)}\n'
          '${_dateFmt.format(tournament.date)}',
        ),
        isThreeLine: true,
        leading: TournamentStatusChip(status: tournament.status),
        trailing: PopupMenuButton<_Action>(
          onSelected: (action) => _handleAction(context, cubit, action),
          itemBuilder: (_) => [
            if (tournament.status == TournamentStatus.pending) ...[
              if (canBeStarted)
                PopupMenuItem(
                  value: _Action.start,
                  child: Text(s.start),
                ),
              PopupMenuItem(
                value: _Action.edit,
                child: Text(s.edit),
              ),
              PopupMenuItem(
                value: _Action.delete,
                child: Text(s.delete),
              ),
            ],
            if (tournament.status == TournamentStatus.active) ...[
              PopupMenuItem(
                value: _Action.finish,
                child: Text(s.finish),
              ),
              PopupMenuItem(
                value: _Action.checkDetails,
                child: Text(s.checkDetails),
              ),
            ],
            if (tournament.status == TournamentStatus.finished)
              PopupMenuItem(
                value: _Action.checkDetails,
                child: Text(s.checkDetails),
              ),
          ],
        ),
      ),
    );
  }

  void _handleAction(
    BuildContext context,
    OrganizerTournamentsCubit cubit,
    _Action action,
  ) {
    final id = int.parse(tournament.tournamentId);
    switch (action) {
      case _Action.edit:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: cubit,
            child: TournamentForm(existing: tournament),
          ),
        ));
      case _Action.start:
        cubit.start(id);
      case _Action.finish:
        cubit.finish(id);
      case _Action.delete:
        _confirmDelete(context, cubit, id);
      case _Action.checkDetails:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: cubit,
            child: TournamentForm(existing: tournament, readOnly: true),
          ),
        ));
    }
  }

  void _confirmDelete(
      BuildContext context, OrganizerTournamentsCubit cubit, int id) {
    final s = S.of(context);
    showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(s.deleteTournament),
        content: Text(s.deleteTournamentConfirm(tournament.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(s.delete),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) cubit.delete(id);
    });
  }
}

enum _Action { edit, start, finish, delete, checkDetails }
