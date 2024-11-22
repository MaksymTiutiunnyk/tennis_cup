import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/repositories/tournament_repository.dart';

class PlayersTournamentsNotifier
    extends StateNotifier<AsyncValue<List<Tournament>>> {
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;

  PlayersTournamentsNotifier() : super(const AsyncValue.data([]));

  Future<void> fetchTournaments({
    int limit = 5,
    required String player1Id,
    required String player2Id,
  }) async {
    if (_isLoading || !_hasMore) return;

    final List<Tournament> existingTournaments = state.value!;

    _isLoading = true;
    state = const AsyncValue.loading();

    final result = await TournamentRepository.fetchPlayersTournaments(
      player1Id: player1Id,
      player2Id: player2Id,
      limit: limit,
      startAfter: _lastDocument,
    );

    final newTournaments = result['tournaments'] as List<Tournament>;
    _lastDocument = result['lastDocument'] as DocumentSnapshot?;

    final List<Tournament> allTournaments = [
      ...existingTournaments,
      ...newTournaments
    ];

    if (newTournaments.isEmpty) {
      _hasMore = false;
    }

    state = AsyncValue.data(allTournaments);
    _isLoading = false;
  }

  void reset() {
    state = const AsyncValue.data([]);
    _lastDocument = null;
    _hasMore = true;
    _isLoading = false;
  }
}

final playersTournamentsProvider = StateNotifierProvider<
    PlayersTournamentsNotifier,
    AsyncValue<List<Tournament>>>((ref) => PlayersTournamentsNotifier());
