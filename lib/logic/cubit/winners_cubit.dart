import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

sealed class WinnersState {}

final class WinnersLoading extends WinnersState {}

final class WinnersLoaded extends WinnersState {
  final List<Tournament> tournaments;
  WinnersLoaded(this.tournaments);
}

final class WinnersError extends WinnersState {}

class WinnersCubit extends Cubit<WinnersState> {
  final TournamentRepository tournamentRepository;

  WinnersCubit({required this.tournamentRepository})
      : super(WinnersLoading()) {
    _fetch();
  }

  void _fetch() async {
    try {
      final tournaments = await tournamentRepository.fetchWinnersTournaments();
      emit(WinnersLoaded(tournaments));
    } catch (_) {
      emit(WinnersError());
    }
  }
}
