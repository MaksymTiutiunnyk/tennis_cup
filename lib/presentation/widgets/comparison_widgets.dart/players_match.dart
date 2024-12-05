import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/data/data_providers/tournament_api.dart';
import 'package:tennis_cup/logic/cubit/arena_filter_cubit.dart';
import 'package:tennis_cup/logic/cubit/schedule_date_cubit.dart';
import 'package:tennis_cup/logic/cubit/tab_index_cubit.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';
import 'package:tennis_cup/logic/cubit/time_filter_cubit.dart';
import 'package:tennis_cup/presentation/screens/tabs.dart';

DateFormat dateTimeFormatter = DateFormat('yyyy-MM-dd, HH:mm');
DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

// ignore: must_be_immutable
class PlayersMatch extends ConsumerWidget {
  final tournamentRepository =
      TournamentRepository(tournamentApi: TournamentApi());

  final Player player1, player2;
  Match match;
  Tournament tournament;

  PlayersMatch({
    super.key,
    required this.player1,
    required this.player2,
    required this.match,
    required this.tournament,
  });

  void _updateTournamentAndMatch(Tournament tournament) {
    this.tournament = tournament;
    for (final match in tournament.matches!) {
      if (match.matchId == this.match.matchId) {
        this.match = match;
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersTournamentProvider =
        StreamProvider.autoDispose<Tournament>((ref) async* {
      await for (final _
          in tournamentRepository.watchMatchChanges(tournament.tournamentId)) {
        Tournament fetchedTournament =
            await tournamentRepository.fetchTournamentById(
                tournamentId: tournament.tournamentId);
        _updateTournamentAndMatch(fetchedTournament);
        yield fetchedTournament;
      }
    });
    ref.watch(playersTournamentProvider);

    final bool isPlayer1Blue = match.bluePlayer == player1;

    final int player1Score = isPlayer1Blue ? match.blueScore : match.redScore;
    final int player2Score = isPlayer1Blue ? match.redScore : match.blueScore;

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
      (index) => '${player1SetScores[index]}-${player2SetScores[index]}',
    );

    return InkWell(
      onTap: () {
        context.read<ScheduleDateCubit>().selectDate(tournament.date);
        context.read<TimeFilterCubit>().selectTime(tournament.time);
        context.read<ArenaFilterCubit>().selectArena(tournament.arena);
        context.read<TabIndexCubit>().selectTab(1);

        Navigator.of(context)
            .push(MaterialPageRoute(builder: (ctx) => const Tabs()));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
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
                        : Theme.of(context).colorScheme.onPrimaryContainer,
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
          ),
        ),
      ),
    );
  }
}
