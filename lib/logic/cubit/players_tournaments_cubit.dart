import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/data/data_providers/tournament_api.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

part 'players_tournaments_state.dart';

class PlayersTournamentsCubit extends Cubit<PlayersTournamentsState> {
  final TournamentRepository tournamentRepository =
      const TournamentRepository(tournamentApi: TournamentApi());

  final Player player1;
  final Player player2;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;

  PlayersTournamentsCubit(this.player1, this.player2)
      : super(const PlayersTournamentsState(tournaments: [], isLoading: false));

  Future<void> fetchTournaments({int limit = 2}) async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    emit(state.copyWith(isLoading: true));

    try {
      final result = await tournamentRepository.fetchPlayersTournaments(
        player1Id: player1.playerId,
        player2Id: player2.playerId,
        limit: limit,
        startAfter: _lastDocument,
      );

      final newTournaments = result['tournaments'] as List<Tournament>;
      _lastDocument = result['lastDocument'] as DocumentSnapshot?;

      final allTournaments = [...state.tournaments, ...newTournaments];

      if (newTournaments.isEmpty) {
        _hasMore = false;
      }

      emit(PlayersTournamentsState(
        tournaments: allTournaments,
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
