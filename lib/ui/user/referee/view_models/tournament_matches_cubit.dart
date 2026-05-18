import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/utils/error_utils.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/repositories/match_repository.dart';

sealed class TournamentMatchesState {}

class TournamentMatchesLoading extends TournamentMatchesState {}

class TournamentMatchesLoaded extends TournamentMatchesState {
  final List<Match> matches;
  TournamentMatchesLoaded(this.matches);
}

class TournamentMatchesError extends TournamentMatchesState {
  final String message;
  TournamentMatchesError(this.message);
}

class TournamentMatchesCubit extends Cubit<TournamentMatchesState> {
  final MatchRepository _repository;
  final int tournamentId;

  TournamentMatchesCubit({
    required MatchRepository repository,
    required this.tournamentId,
  })  : _repository = repository,
        super(TournamentMatchesLoading()) {
    load();
  }

  Future<void> load() async {
    emit(TournamentMatchesLoading());
    try {
      final matches =
          await _repository.fetchMatchesForTournament(tournamentId);
      _sort(matches);
      if (!isClosed) emit(TournamentMatchesLoaded(matches));
    } catch (e) {
      if (!isClosed) emit(TournamentMatchesError(errorMessage(e)));
    }
  }

  void _sort(List<Match> matches) {
    int rank(Match m) => switch (m.status) {
          MatchStatus.active => 0,
          MatchStatus.pending => 1,
          _ => 2,
        };
    matches.sort((a, b) {
      final r = rank(a).compareTo(rank(b));
      return r != 0 ? r : a.scheduledStart.compareTo(b.scheduledStart);
    });
  }
}
