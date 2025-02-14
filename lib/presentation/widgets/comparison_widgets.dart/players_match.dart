import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/logic/cubit/match_changes_cubit.dart';
import 'package:tennis_cup/logic/cubit/players_match_cubit.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/presentation/screens/tabs.dart';

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

    return MultiBlocProvider(
      providers: [
        BlocProvider<PlayersMatchCubit>(
          create: (context) => PlayersMatchCubit(match),
        ),
        BlocProvider<MatchChangesCubit>(
          create: (context) => MatchChangesCubit(match),
        ),
      ],
      child: BlocListener<MatchChangesCubit, void>(
        listener: (context, state) {
          context.read<PlayersMatchCubit>().fetchPlayersMatch(
              context.read<PlayersMatchCubit>().state.matchId);
        },
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<Tabs>(
                builder: (ctx) => Tabs(
                  initialTabIndex: 1,
                  initialDate: tournament.date,
                  initialArena: tournament.arena,
                  initialTime: tournament.time,
                ),
              ),
            );
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: BlocBuilder<PlayersMatchCubit, Match>(
                builder: (context, state) {
                  final match = context.read<PlayersMatchCubit>().state;

                  final int player1Score =
                      isPlayer1Blue ? match.blueScore : match.redScore;
                  final int player2Score =
                      isPlayer1Blue ? match.redScore : match.blueScore;

                  final List<int> player1SetScores =
                      isPlayer1Blue ? match.blueSetScores : match.redSetScores;
                  final List<int> player2SetScores =
                      isPlayer1Blue ? match.redSetScores : match.blueSetScores;

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
                        dateTimeFormatter.format(match.dateTime),
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
      ),
    );
  }
}
