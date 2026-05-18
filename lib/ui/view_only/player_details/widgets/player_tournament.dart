import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/gender.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/routing/app_router.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/arena_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/schedule_date_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/time_filter_cubit.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd');

class PlayerTournament extends StatelessWidget {
  final Tournament tournament;
  final User player;
  const PlayerTournament(
      {required this.player, required this.tournament, super.key});

  String _getSetsRatio() {
    int setsWon = 0;
    int setsLost = 0;

    for (final match in tournament.matches!) {
      if (match.bluePlayer.id == player.id) {
        setsWon += match.blueScore;
        setsLost += match.redScore;
      } else if (match.redPlayer.id == player.id) {
        setsWon += match.redScore;
        setsLost += match.blueScore;
      }
    }

    return '$setsWon : $setsLost';
  }

  int _getWins() {
    int wins = 0;
    for (final match in tournament.matches!) {
      if (match.bluePlayer.id == player.id && match.blueScore == 3) {
        wins++;
      } else if (match.redPlayer.id == player.id && match.redScore == 3) {
        wins++;
      }
    }
    return wins;
  }

  int _getLoses() {
    int loses = 0;
    for (final match in tournament.matches!) {
      if (match.bluePlayer.id == player.id && match.redScore == 3) {
        loses++;
      } else if (match.redPlayer.id == player.id && match.blueScore == 3) {
        loses++;
      }
    }
    return loses;
  }

  String _timeLabel(S s, Time t) => switch (t) {
        Time.Morning => s.timeLabelMorning,
        Time.Day => s.timeLabelDay,
        Time.Evening => s.timeLabelEvening,
        Time.Night => s.timeLabelNight,
        Time.Midnight => s.timeLabelMidnight,
      };

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final index = tournament.players.indexWhere((p) => p.id == player.id);
    final tournamentGender = tournament.gender.toLowerCase() == Gender.male.name
        ? s.menLabel
        : s.womenLabel;

    return InkWell(
      onTap: () {
        context.read<ScheduleDateCubit>().selectDate(tournament.date);
        context.read<ArenaFilterCubit>().selectArena(tournament.arena);
        context.read<TimeFilterCubit>().selectTime(tournament.time);
        context.go(AppRoutes.viewSchedule);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 16,
                    child: Icon(
                      Icons.emoji_events,
                      color: tournament.isFinished
                          ? Colors.grey
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '${formatter.format(tournament.date)} $tournamentGender, ${_timeLabel(s, tournament.time)} ${tournament.arena.title}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${s.labelPosition}:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${index >= 0 ? tournament.places.elementAtOrNull(index) ?? '' : ''}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.labelWins,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    _getWins().toString(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.labelLosses,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    _getLoses().toString(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.labelSetsRatio,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    _getSetsRatio(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${s.labelPoints}:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    index >= 0
                        ? tournament.points.elementAtOrNull(index).toString()
                        : '—',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
