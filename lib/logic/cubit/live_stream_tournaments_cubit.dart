import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

sealed class LiveStreamTournamentsState {}

final class LiveStreamTournamentsLoading extends LiveStreamTournamentsState {}

final class LiveStreamTournamentsLoaded extends LiveStreamTournamentsState {
  final List<Tournament> tournaments;
  LiveStreamTournamentsLoaded(this.tournaments);
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
      final tournaments =
          await tournamentRepository.fetchLiveStreamMatchesTournaments();
      emit(LiveStreamTournamentsLoaded(tournaments));
    } catch (_) {
      emit(LiveStreamTournamentsError());
    }
  }
}
