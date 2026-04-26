import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/page_request.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

part 'player_tournaments_state.dart';

class PlayerTournamentsCubit extends Cubit<PlayerTournamentsState> {
  final TournamentRepository tournamentRepository;
  final Player player1;
  PageRequest _currentPage = const PageRequest(page: 0, size: 2);
  bool _hasMore = true;
  bool _isLoading = false;

  PlayerTournamentsCubit(
    this.player1, {
    required this.tournamentRepository,
  }) : super(const PlayerTournamentsState(tournaments: [], isLoading: false));

  Future<void> fetchTournaments() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    emit(state.copyWith(isLoading: true));

    try {
      final result = await tournamentRepository.fetchPlayersTournaments(
        player1Id: player1.playerId,
        page: _currentPage,
      );

      if (result.hasMore) _currentPage = _currentPage.next;
      _hasMore = result.hasMore;

      emit(PlayerTournamentsState(
        tournaments: [...state.tournaments, ...result.items],
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Error loading tournaments',
      ));
    } finally {
      _isLoading = false;
    }
  }
}
