import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/winner_view.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

sealed class WinnersState {}

final class WinnersLoading extends WinnersState {}

final class WinnersLoaded extends WinnersState {
  final List<WinnerView> winners;
  WinnersLoaded(this.winners);
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
      final winners = await tournamentRepository.fetchWinners();
      emit(WinnersLoaded(winners));
    } catch (_) {
      emit(WinnersError());
    }
  }
}
