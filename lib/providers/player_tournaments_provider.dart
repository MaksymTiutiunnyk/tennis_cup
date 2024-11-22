import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/repositories/tournament_repository.dart';

class PlayerTournamentsNotifier
    extends StateNotifier<AsyncValue<List<Tournament>>> {
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;
  final Player player;

  PlayerTournamentsNotifier(this.player) : super(const AsyncValue.data([]));

  Future<void> fetchTournaments({int limit = 5}) async {
    if (_isLoading || !_hasMore) return;

    final List<Tournament> existingTournaments = state.value!;

    _isLoading = true;
    state = const AsyncValue.loading();

    final result = await TournamentRepository.fetchPlayerTournaments(
      playerId: player.playerId,
      limit: limit,
      startAfter: _lastDocument,
    );

    final newTournaments =
        await Future.wait(result['tournaments'] as List<Future<Tournament>>);
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
