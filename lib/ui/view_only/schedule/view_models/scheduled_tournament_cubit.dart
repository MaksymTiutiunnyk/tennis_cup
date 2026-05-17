import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/utils/error_utils.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

part 'scheduled_tournament_state.dart';

class ScheduledTournamentCubit extends Cubit<ScheduledTournamentState> {
  final TournamentRepository tournamentRepository;

  ScheduledTournamentCubit({required this.tournamentRepository})
      : super(ScheduledTournamentFetching());

  Future<void> fetchScheduledTournament({
    required DateTime date,
    required Arena arena,
    required Time time,
  }) async {
    emit(ScheduledTournamentFetching());
    try {
      final tournaments = await tournamentRepository.fetchScheduledTournament(
        tournamentDate: date,
        tournamentArena: arena,
        tournamentTime: time,
        statuses: ['ACTIVE', 'FINISHED'],
      );
      if (isClosed) return;
      if (tournaments.isEmpty) {
        emit(TournamentNotFound());
        return;
      }
      emit(ScheduledTournamentFetched(tournaments.first));
    } catch (e) {
      if (isClosed) return;
      emit(ScheduledTournamentError(errorMessage(e)));
    }
  }

  Future<void> fetchScheduledTournamentWithoutLoading({
    required DateTime date,
    required Arena arena,
    required Time time,
  }) async {
    try {
      final tournaments = await tournamentRepository.fetchScheduledTournament(
        tournamentDate: date,
        tournamentArena: arena,
        tournamentTime: time,
        statuses: ['ACTIVE', 'FINISHED'],
      );
      if (isClosed) return;
      if (tournaments.isEmpty) return;
      emit(ScheduledTournamentFetched(tournaments.first));
    } catch (e) {
      if (isClosed) return;
      emit(ScheduledTournamentError(errorMessage(e)));
    }
  }
}
