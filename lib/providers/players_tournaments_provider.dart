import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/repositories/tournament_repository.dart';

class PlayersTournamentsNotifier extends StateNotifier<List<Tournament>> {
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;

  PlayersTournamentsNotifier() : super([]);

  Future<void> fetchTournaments(
      {int limit = 5,
      required String player1Id,
      required String player2Id}) async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    final result = await TournamentRepository.fetchPlayersTournaments(
      player1Id: player1Id,
      player2Id: player2Id,
      limit: limit,
      startAfter: _lastDocument,
    );

    final newTournaments = result['tournaments'] as List<Tournament>;
    _lastDocument = result['lastDocument'] as DocumentSnapshot?;

    if (newTournaments.isNotEmpty) {
      state = [...state, ...newTournaments];
    } else {
      _hasMore = false;
    }
    _isLoading = false;
  }
}

final playersTournamentsProvider =
    StateNotifierProvider<PlayersTournamentsNotifier, List<Tournament>>(
        (ref) => PlayersTournamentsNotifier());
