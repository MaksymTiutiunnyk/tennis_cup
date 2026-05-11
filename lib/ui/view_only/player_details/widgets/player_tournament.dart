import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/routing/app_router.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/arena_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/schedule_date_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/time_filter_cubit.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd');

class PlayerTournament extends StatelessWidget {
  final Tournament tournament;
  final Player player;
  const PlayerTournament(
      {required this.player, required this.tournament, super.key});

  String _getSetsRatio() {
    int setsWon = 0;
    int setsLost = 0;

    for (final match in tournament.matches!) {
      if (match.bluePlayer.userId == player.userId) {
        setsWon += match.blueScore;
        setsLost += match.redScore;
      } else if (match.redPlayer.userId == player.userId) {
        setsWon += match.redScore;
        setsLost += match.blueScore;
      }
    }

    return '$setsWon : $setsLost';
  }

  int _getWins() {
    int wins = 0;
    for (final match in tournament.matches!) {
      if (match.bluePlayer.userId == player.userId && match.blueScore == 3) {
        wins++;
      } else if (match.redPlayer.userId == player.userId &&
          match.redScore == 3) {
        wins++;
      }
    }
    return wins;
  }

  int _getLoses() {
    int loses = 0;
    for (final match in tournament.matches!) {
      if (match.bluePlayer.userId == player.userId && match.redScore == 3) {
        loses++;
      } else if (match.redPlayer.userId == player.userId &&
          match.blueScore == 3) {
        loses++;
      }
    }
    return loses;
  }

  @override
  Widget build(BuildContext context) {
    final index =
        tournament.players.indexWhere((p) => p.userId == player.userId);

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
                      // TODO: temporary fix until backend generates tournaments with accepted invitations
                      '${formatter.format(tournament.date)} ${index >= 0 ? tournament.players.elementAt(index).sex.name : ''}, ${tournament.time.name} ${tournament.arena.title}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Position:',
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
                    'Wins:',
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
                    'Loses:',
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
                    'Sets ratio:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    _getSetsRatio().toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Points:',
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
