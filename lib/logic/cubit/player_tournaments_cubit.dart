import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/data/data_providers/tournament_api.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

part 'player_tournaments_state.dart';

class PlayerTournamentsCubit extends Cubit<PlayerTournamentsState> {
  final TournamentRepository tournamentRepository =
      TournamentRepository(tournamentApi: TournamentApi());

  final Player player;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;

  PlayerTournamentsCubit(this.player)
      : super(PlayerTournamentsState(tournaments: [], isLoading: false));

  Future<void> fetchTournaments({int limit = 2}) async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    emit(state.copyWith(isLoading: true));

    try {
      final result = await tournamentRepository.fetchPlayerTournaments(
        playerId: player.playerId,
        limit: limit,
        startAfter: _lastDocument,
      );

      final newTournaments =
          await Future.wait(result['tournaments'] as List<Future<Tournament>>);
      _lastDocument = result['lastDocument'] as DocumentSnapshot?;
      print("Updated lastDocument: $_lastDocument");

      final allTournaments = [...state.tournaments, ...newTournaments];

      if (newTournaments.isEmpty) {
        _hasMore = false;
      }

      emit(PlayerTournamentsState(tournaments: allTournaments, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Error loading tournaments'));
    } finally {
      _isLoading = false;
    }
  }
}
