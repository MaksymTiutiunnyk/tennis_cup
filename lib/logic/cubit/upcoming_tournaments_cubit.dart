import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

sealed class UpcomingTournamentsState {}

final class UpcomingTournamentsLoading extends UpcomingTournamentsState {}

final class UpcomingTournamentsLoaded extends UpcomingTournamentsState {
  final List<Tournament> tournaments;
  UpcomingTournamentsLoaded(this.tournaments);
}

final class UpcomingTournamentsError extends UpcomingTournamentsState {}

class UpcomingTournamentsCubit extends Cubit<UpcomingTournamentsState> {
  final TournamentRepository tournamentRepository;

  UpcomingTournamentsCubit({required this.tournamentRepository})
      : super(UpcomingTournamentsLoading()) {
    _fetch();
  }

  void _fetch() async {
    try {
      final tournaments =
          await tournamentRepository.fetchUpcomingMatchesTournaments();
      emit(UpcomingTournamentsLoaded(tournaments));
    } catch (_) {
      emit(UpcomingTournamentsError());
    }
  }
}
