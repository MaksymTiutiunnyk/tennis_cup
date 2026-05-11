import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

part 'player_tournaments_state.dart';

class PlayerTournamentsCubit extends Cubit<PlayerTournamentsState> {
  final TournamentRepository tournamentRepository;
  final Player player1;
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
      final result = await tournamentRepository.fetchPlayersTournaments(
        userId: player1.userId.toString(),
        page: _currentPage,
      );
      if (result.hasMore) _currentPage = _currentPage.next;

      final existing = current is PlayerTournamentsLoaded
          ? current.tournaments
          : <Tournament>[];
      emit(PlayerTournamentsLoaded(
        tournaments: [...existing, ...result.items],
        hasMore: result.hasMore,
      ));
    } catch (e) {
      emit(const PlayerTournamentsError('Error loading tournaments'));
    } finally {
      _isLoading = false;
    }
  }
}
