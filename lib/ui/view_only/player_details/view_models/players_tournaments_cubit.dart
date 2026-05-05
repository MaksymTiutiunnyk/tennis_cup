import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

part 'players_tournaments_state.dart';

class PlayersTournamentsCubit extends Cubit<PlayersTournamentsState> {
  final TournamentRepository tournamentRepository;
  final Player player1;
  final Player player2;
  PageRequest _currentPage = const PageRequest(page: 0, size: 2);
  bool _isLoading = false;

  PlayersTournamentsCubit(
    this.player1,
    this.player2, {
    required this.tournamentRepository,
  }) : super(const PlayersTournamentsLoading());

  Future<void> fetchTournaments() async {
    if (_isLoading) return;
    final current = state;
    if (current is PlayersTournamentsLoaded && !current.hasMore) return;

    _isLoading = true;
    try {
      final result = await tournamentRepository.fetchPlayersTournaments(
        player1Id: player1.playerId,
        player2Id: player2.playerId,
        page: _currentPage,
      );
      if (result.hasMore) _currentPage = _currentPage.next;

      final existing = current is PlayersTournamentsLoaded
          ? current.tournaments
          : <Tournament>[];
      emit(PlayersTournamentsLoaded(
        tournaments: [...existing, ...result.items],
        hasMore: result.hasMore,
      ));
    } catch (e) {
      emit(const PlayersTournamentsError('Error loading tournaments'));
    } finally {
      _isLoading = false;
    }
  }
}
