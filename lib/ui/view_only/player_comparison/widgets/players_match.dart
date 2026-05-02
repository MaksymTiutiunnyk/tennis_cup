import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/routing/app_router.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/live_match_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/arena_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/schedule_date_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/time_filter_cubit.dart';

DateFormat dateTimeFormatter = DateFormat('yyyy-MM-dd, HH:mm');
DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

class PlayersMatch extends StatelessWidget {
  final Player player1, player2;
  final Match match;
  final Tournament tournament;

  const PlayersMatch({
    super.key,
    required this.player1,
    required this.player2,
    required this.match,
    required this.tournament,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPlayer1Blue = match.bluePlayer == player1;

    return BlocProvider<LiveMatchCubit>(
      create: (_) => LiveMatchCubit(
        matchId: match.matchId,
        matchRepository: ServiceLocator.matchRepository,
      ),
      child: InkWell(
        onTap: () {
          context.read<ScheduleDateCubit>().selectDate(tournament.date);
          context.read<ArenaFilterCubit>().selectArena(tournament.arena);
          context.read<TimeFilterCubit>().selectTime(tournament.time);
          context.go(AppRoutes.viewSchedule);
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: BlocBuilder<LiveMatchCubit, Match?>(
              builder: (context, state) {
                final currentMatch = state ?? match;

                final int player1Score = isPlayer1Blue
                    ? currentMatch.blueScore
                    : currentMatch.redScore;
                final int player2Score = isPlayer1Blue
                    ? currentMatch.redScore
                    : currentMatch.blueScore;

                final List<int> player1SetScores = isPlayer1Blue
                    ? currentMatch.blueSetScores
                    : currentMatch.redSetScores;
                final List<int> player2SetScores = isPlayer1Blue
                    ? currentMatch.redSetScores
                    : currentMatch.blueSetScores;

                int setsPlayed = player1Score + player2Score;
                if (player1Score != 3 && player2Score != 3) {
                  setsPlayed++;
                }
                final List<String> displayedSetScores = List.generate(
                  setsPlayed,
                  (index) =>
                      '${player1SetScores[index]}-${player2SetScores[index]}',
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateTimeFormatter.format(currentMatch.dateTime),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: tournament.isFinished
                              ? Colors.grey
                              : Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                            '${dateFormatter.format(tournament.date)} ${tournament.players[0].sex.name} ${tournament.time.name} ${tournament.arena.title}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$player1Score : $player2Score',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '(${displayedSetScores.join(', ')})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
