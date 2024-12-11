import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/logic/cubit/arena_filter_cubit.dart';
import 'package:tennis_cup/logic/cubit/schedule_date_cubit.dart';
import 'package:tennis_cup/logic/cubit/scheduled_tournament_cubit.dart';
import 'package:tennis_cup/logic/cubit/time_filter_cubit.dart';
import 'package:tennis_cup/logic/cubit/tournament_changes_cubit.dart';
import 'package:tennis_cup/presentation/widgets/schedule_widgets/schedule_panel.dart';
import 'package:tennis_cup/presentation/widgets/schedule_widgets/scheduled_matches.dart';
import 'package:tennis_cup/presentation/widgets/schedule_widgets/tournament_results.dart';

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ScheduledTournamentCubit>(
      create: (context) => ScheduledTournamentCubit(
        scheduleDateCubit: BlocProvider.of<ScheduleDateCubit>(context),
        arenaFilterCubit: BlocProvider.of<ArenaFilterCubit>(context),
        timeFilterCubit: BlocProvider.of<TimeFilterCubit>(context),
      )..fetchScheduledTournament(),
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SchedulePanel(),
            Flexible(
              fit: FlexFit.loose,
              child: BlocBuilder<ScheduledTournamentCubit,
                  ScheduledTournamentState>(
                builder: (context, state) {
                  if (state is ScheduledTournamentError) {
                    return const Center(
                      child: Text('Ooops, something went wrong'),
                    );
                  }
                  if (state is TournamentNotFound) {
                    return const Center(child: Text('Tournament is not found'));
                  }

                  if (state is ScheduledTournamentFetched) {
                    return BlocProvider<TournamentChangesCubit>(
                      create: (context) => TournamentChangesCubit(
                        tournamentId: state.tournament.tournamentId,
                      ),
                      child: BlocListener<TournamentChangesCubit, void>(
                        listener: (context, state) {
                          context
                              .read<ScheduledTournamentCubit>()
                              .fetchScheduledTournamentWithoutLoading();
                        },
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxHeight >= 600) {
                              return Column(
                                children: [
                                  ScheduledMatches(
                                    tournament: state.tournament,
                                  ),
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
