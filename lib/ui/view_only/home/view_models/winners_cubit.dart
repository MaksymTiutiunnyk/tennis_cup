import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/utils/error_utils.dart';
import 'package:tennis_cup/data/models/arena_winner.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

sealed class WinnersState {}

final class WinnersLoading extends WinnersState {}

final class WinnersLoaded extends WinnersState {
  final List<ArenaWinner> winners;
  WinnersLoaded(this.winners);
}

final class WinnersError extends WinnersState {
  final String message;
  WinnersError(this.message);
}

class WinnersCubit extends Cubit<WinnersState> {
  final TournamentRepository tournamentRepository;

  WinnersCubit({required this.tournamentRepository})
      : super(WinnersLoading()) {
    _fetch();
  }

  void _fetch() async {
    try {
      final winners = await tournamentRepository.fetchWinners();
      if (isClosed) return;
      emit(WinnersLoaded(winners));
    } catch (e) {
      if (isClosed) return;
      emit(WinnersError(errorMessage(e)));
    }
  }
}
