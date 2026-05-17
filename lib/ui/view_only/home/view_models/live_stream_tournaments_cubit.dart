import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/utils/error_utils.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

sealed class LiveStreamTournamentsState {}

final class LiveStreamTournamentsLoading extends LiveStreamTournamentsState {}

final class LiveStreamTournamentsLoaded extends LiveStreamTournamentsState {
  final List<Match> matches;
  LiveStreamTournamentsLoaded(this.matches);
}

final class LiveStreamTournamentsError extends LiveStreamTournamentsState {
  final String message;
  LiveStreamTournamentsError(this.message);
}

class LiveStreamTournamentsCubit extends Cubit<LiveStreamTournamentsState> {
  final TournamentRepository tournamentRepository;

  LiveStreamTournamentsCubit({required this.tournamentRepository})
      : super(LiveStreamTournamentsLoading()) {
    _fetch();
  }

  void _fetch() async {
    try {
      final matches = await tournamentRepository.fetchLiveStreamMatches();
      if (isClosed) return;
      emit(LiveStreamTournamentsLoaded(matches));
    } catch (e) {
      if (isClosed) return;
      emit(LiveStreamTournamentsError(errorMessage(e)));
    }
  }
}
