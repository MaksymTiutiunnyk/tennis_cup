import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/match_view.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

sealed class LiveStreamTournamentsState {}

final class LiveStreamTournamentsLoading extends LiveStreamTournamentsState {}

final class LiveStreamTournamentsLoaded extends LiveStreamTournamentsState {
  final List<MatchView> matches;
  LiveStreamTournamentsLoaded(this.matches);
}

final class LiveStreamTournamentsError extends LiveStreamTournamentsState {}

class LiveStreamTournamentsCubit extends Cubit<LiveStreamTournamentsState> {
  final TournamentRepository tournamentRepository;

  LiveStreamTournamentsCubit({required this.tournamentRepository})
      : super(LiveStreamTournamentsLoading()) {
    _fetch();
  }

  void _fetch() async {
    try {
      final matches = await tournamentRepository.fetchLiveStreamMatches();
      emit(LiveStreamTournamentsLoaded(matches));
    } catch (_) {
      emit(LiveStreamTournamentsError());
    }
  }
}
