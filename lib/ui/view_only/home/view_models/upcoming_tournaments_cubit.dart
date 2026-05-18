import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/utils/error_utils.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

sealed class UpcomingTournamentsState {}

final class UpcomingTournamentsLoading extends UpcomingTournamentsState {}

final class UpcomingTournamentsLoaded extends UpcomingTournamentsState {
  final List<Match> matches;
  UpcomingTournamentsLoaded(this.matches);
}

final class UpcomingTournamentsError extends UpcomingTournamentsState {
  final String message;
  UpcomingTournamentsError(this.message);
}

class UpcomingTournamentsCubit extends Cubit<UpcomingTournamentsState> {
  final TournamentRepository tournamentRepository;

  UpcomingTournamentsCubit({required this.tournamentRepository})
      : super(UpcomingTournamentsLoading()) {
    _fetch();
  }

  void _fetch() async {
    try {
      final matches = await tournamentRepository.fetchUpcomingMatches();
      if (isClosed) return;
      emit(UpcomingTournamentsLoaded(matches));
    } catch (e) {
      if (isClosed) return;
      emit(UpcomingTournamentsError(errorMessage(e)));
    }
  }
}
