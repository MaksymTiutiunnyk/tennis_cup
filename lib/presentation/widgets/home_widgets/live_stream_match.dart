import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/data/data_providers/tournament_api.dart';
import 'package:tennis_cup/logic/cubit/tab_index_cubit.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/logic/riverpod/arena_filter_provider.dart';
import 'package:tennis_cup/logic/riverpod/schedule_date_provider.dart';
import 'package:tennis_cup/logic/riverpod/time_filter_provider.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';
import 'package:tennis_cup/presentation/widgets/home_widgets/live_stream_match_player.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd');

// ignore: must_be_immutable
class LiveStreamMatch extends ConsumerWidget {
  final tournamentRepository =
      TournamentRepository(tournamentApi: TournamentApi());

  Match match;
  Tournament tournament;

  LiveStreamMatch({super.key, required this.match, required this.tournament});

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
    final liveStreamMatchTournamentProvider =
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
    ref.watch(liveStreamMatchTournamentProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    InkWell(
                      onTap: () {
                        ref
                            .read(scheduleDateProvider.notifier)
                            .selectDate(tournament.date);
                        ref
                            .read(timeFilterProvider.notifier)
                            .selectTime(tournament.time);
                        ref
                            .read(arenaFilterProvider.notifier)
                            .selectArena(tournament.arena);
                        context.read<TabIndexCubit>().selectTab(1);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.circle,
                                  color: tournament.arena.color, size: 8),
                              const SizedBox(width: 8),
                              Text(
                                'Arena: ${tournament.arena.title}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Text(
                            '${formatter.format(match.dateTime)} ${tournament.players[0].sex.name}, ${tournament.time.name} ${tournament.isFinished ? '(Finished)' : ''}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onInverseSurface),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LiveStreamMatchPlayer(
                    player: match.bluePlayer,
                    score: match.blueScore,
                  ),
                  const SizedBox(height: 8),
                  LiveStreamMatchPlayer(
                    player: match.redPlayer,
                    score: match.redScore,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
