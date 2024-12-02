import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

class PlayersTournamentsNotifier
    extends StateNotifier<AsyncValue<List<Tournament>>> {
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;
  final Player player1, player2;

  PlayersTournamentsNotifier({required this.player1, required this.player2}) : super(const AsyncValue.data([]));

  Future<void> fetchTournaments({
    int limit = 5,
  }) async {
    if (_isLoading || !_hasMore) return;

    final List<Tournament> existingTournaments = state.value!;

    _isLoading = true;
    state = const AsyncValue.loading();

    final result = await TournamentRepository.fetchPlayersTournaments(
      player1Id: player1.playerId,
      player2Id: player2.playerId,
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
}
