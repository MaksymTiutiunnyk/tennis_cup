import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/data_providers/tournament_api.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';
import 'package:tennis_cup/logic/cubit/arena_filter_cubit.dart';
import 'package:tennis_cup/logic/cubit/schedule_date_cubit.dart';
import 'package:tennis_cup/logic/cubit/time_filter_cubit.dart';

part 'scheduled_tournament_state.dart';

class ScheduledTournamentCubit extends Cubit<ScheduledTournamentState> {
  final tournamentRepository =
      TournamentRepository(tournamentApi: TournamentApi());

  final ScheduleDateCubit scheduleDateCubit;
  final ArenaFilterCubit arenaFilterCubit;
  final TimeFilterCubit timeFilterCubit;
  late StreamSubscription scheduleDateSubscription;
  late StreamSubscription arenaFilterSubscription;
  late StreamSubscription timeFilterSubscription;

  ScheduledTournamentCubit(
      {required this.scheduleDateCubit,
      required this.arenaFilterCubit,
      required this.timeFilterCubit})
      : super(ScheduledTournamentFetching()) {
    scheduleDateSubscription = scheduleDateCubit.stream.listen((dateTime) {
      fetchScheduledTournament();
    });
    arenaFilterSubscription = arenaFilterCubit.stream.listen((arena) {
      fetchScheduledTournament();
    });
    timeFilterSubscription = timeFilterCubit.stream.listen((time) {
      fetchScheduledTournament();
    });
  }

  void fetchScheduledTournament() async {
    emit(ScheduledTournamentFetching());

    final tournaments = await tournamentRepository.fetchScheduledTournament(
        tournamentDate: scheduleDateCubit.state,
        tournamentArena: arenaFilterCubit.state,
        tournamentTime: timeFilterCubit.state);

    if (tournaments.isEmpty) {
      emit(TournamentNotFound());
      return;
    }

    emit(ScheduledTournamentFetched(tournaments.first));
  }

  void fetchScheduledTournamentWithoutLoading() async {
    final tournaments = await tournamentRepository.fetchScheduledTournament(
        tournamentDate: scheduleDateCubit.state,
        tournamentArena: arenaFilterCubit.state,
        tournamentTime: timeFilterCubit.state);

    if (tournaments.isEmpty) {
      return;
    }

    emit(ScheduledTournamentFetched(tournaments.first));
  }

  @override
  Future<void> close() {
    scheduleDateSubscription.cancel();
    arenaFilterSubscription.cancel();
    timeFilterSubscription.cancel();
    return super.close();
  }
}
