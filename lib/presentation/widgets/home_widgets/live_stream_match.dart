import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/data_providers/tournament_api.dart';
import 'package:tennis_cup/logic/cubit/arena_filter_cubit.dart';
import 'package:tennis_cup/logic/cubit/live_stream_match_cubit.dart';
import 'package:tennis_cup/logic/cubit/match_changes_cubit.dart';
import 'package:tennis_cup/logic/cubit/schedule_date_cubit.dart';
import 'package:tennis_cup/logic/cubit/tab_index_cubit.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';
import 'package:tennis_cup/logic/cubit/time_filter_cubit.dart';
import 'package:tennis_cup/presentation/widgets/home_widgets/live_stream_match_player.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd');

class LiveStreamMatch extends StatelessWidget {
  final tournamentRepository =
      const TournamentRepository(tournamentApi: TournamentApi());

  final Match match;
  final Tournament tournament;

  const LiveStreamMatch(
      {super.key, required this.match, required this.tournament});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MatchChangesCubit>(
          create: (context) => MatchChangesCubit(match),
        ),
        BlocProvider<LiveStreamMatchCubit>(
          create: (context) => LiveStreamMatchCubit(match),
        ),
      ],
      child: BlocListener<MatchChangesCubit, void>(
        listener: (context, state) {
          context.read<LiveStreamMatchCubit>().fetchLiveStreamMatch(
              context.read<LiveStreamMatchCubit>().state.matchId);
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                            context
                                .read<ScheduleDateCubit>()
                                .selectDate(tournament.date);
                            context
                                .read<TimeFilterCubit>()
                                .selectTime(tournament.time);
                            context
                                .read<ArenaFilterCubit>()
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
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              Text(
                                '${formatter.format(tournament.date)} ${tournament.players[0].sex.name}, ${tournament.time.name} ${tournament.isFinished ? '(Finished)' : ''}',
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
                child: BlocBuilder<LiveStreamMatchCubit, Match>(
                  builder: (context, state) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onInverseSurface),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LiveStreamMatchPlayer(
                          player: context
                              .read<LiveStreamMatchCubit>()
                              .state
                              .bluePlayer,
                          score: context
                              .read<LiveStreamMatchCubit>()
                              .state
                              .blueScore,
                        ),
                        const SizedBox(height: 8),
                        LiveStreamMatchPlayer(
                          player: context
                              .read<LiveStreamMatchCubit>()
                              .state
                              .redPlayer,
                          score: context
                              .read<LiveStreamMatchCubit>()
                              .state
                              .redScore,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
