import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/utils/error_utils.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

part 'player_tournaments_state.dart';

class PlayerTournamentsCubit extends Cubit<PlayerTournamentsState> {
  final TournamentRepository tournamentRepository;
  final User player1;
  PageRequest _currentPage = const PageRequest(page: 0, size: 2);
  bool _isLoading = false;

  PlayerTournamentsCubit(
    this.player1, {
    required this.tournamentRepository,
  }) : super(const PlayerTournamentsLoading());

  Future<void> fetchTournaments() async {
    if (_isLoading) return;
    final current = state;
    if (current is PlayerTournamentsLoaded && !current.hasMore) return;

    _isLoading = true;
    try {
      final result = await tournamentRepository.fetchPlayerTournaments(
        playerId: player1.id.toString(),
        page: _currentPage,
      );
      if (result.hasMore) _currentPage = _currentPage.next;

      final existing = current is PlayerTournamentsLoaded
          ? current.tournaments
          : <Tournament>[];
      if (isClosed) return;
      emit(PlayerTournamentsLoaded(
        tournaments: [...existing, ...result.items],
        hasMore: result.hasMore,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(PlayerTournamentsError(errorMessage(e)));
    } finally {
      _isLoading = false;
    }
  }
}
