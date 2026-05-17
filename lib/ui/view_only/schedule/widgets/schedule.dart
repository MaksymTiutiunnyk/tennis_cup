import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/arena_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/arenas_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/schedule_date_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/scheduled_tournament_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/time_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/tournament_changes_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/widgets/schedule_panel.dart';
import 'package:tennis_cup/ui/view_only/schedule/widgets/scheduled_matches.dart';
import 'package:tennis_cup/ui/view_only/schedule/widgets/tournament_results.dart';

class Schedule extends StatelessWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ArenasCubit(
            arenaRepository: ServiceLocator.arenaRepository,
          ),
        ),
        BlocProvider(
          create: (context) => ScheduledTournamentCubit(
            tournamentRepository: ServiceLocator.tournamentRepository,
          )..fetchScheduledTournament(
              date: context.read<ScheduleDateCubit>().state,
              arena: context.read<ArenaFilterCubit>().state,
              time: context.read<TimeFilterCubit>().state,
            ),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ScheduleDateCubit, DateTime>(
            listener: (context, date) =>
                context.read<ScheduledTournamentCubit>().fetchScheduledTournament(
                      date: date,
                      arena: context.read<ArenaFilterCubit>().state,
                      time: context.read<TimeFilterCubit>().state,
                    ),
          ),
          BlocListener<ArenaFilterCubit, Arena>(
            listener: (context, arena) =>
                context.read<ScheduledTournamentCubit>().fetchScheduledTournament(
                      date: context.read<ScheduleDateCubit>().state,
                      arena: arena,
                      time: context.read<TimeFilterCubit>().state,
                    ),
          ),
          BlocListener<TimeFilterCubit, Time>(
            listener: (context, time) =>
                context.read<ScheduledTournamentCubit>().fetchScheduledTournament(
                      date: context.read<ScheduleDateCubit>().state,
                      arena: context.read<ArenaFilterCubit>().state,
                      time: time,
                    ),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SchedulePanel(),
            Flexible(
              fit: FlexFit.loose,
              child: BlocBuilder<ScheduledTournamentCubit, ScheduledTournamentState>(
                builder: (context, state) {
                  if (state is ScheduledTournamentError) {
                    return Center(
                      child: Text(S.of(context).oopsSomethingWentWrong),
                    );
                  }
                  if (state is TournamentNotFound) {
                    return Center(
                        child: Text(S.of(context).tournamentNotFound));
                  }
                  if (state is ScheduledTournamentFetched) {
                    return BlocProvider<TournamentChangesCubit>(
                      create: (context) => TournamentChangesCubit(
                        tournamentId: state.tournament.tournamentId,
                        tournamentRepository: ServiceLocator.tournamentRepository,
                      ),
                      child: BlocListener<TournamentChangesCubit, void>(
                        listener: (context, _) => context
                            .read<ScheduledTournamentCubit>()
                            .fetchScheduledTournamentWithoutLoading(
                              date: context.read<ScheduleDateCubit>().state,
                              arena: context.read<ArenaFilterCubit>().state,
                              time: context.read<TimeFilterCubit>().state,
                            ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxHeight >= 600) {
                              return Column(
                                children: [
                                  ScheduledMatches(tournament: state.tournament),
                                  TournamentResults(state.tournament),
                                ],
                              );
                            }
                            return SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ScheduledMatches(
                                    tournament: state.tournament,
                                    isScrollable: false,
                                  ),
                                  TournamentResults(state.tournament),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

