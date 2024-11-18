import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/repositories/tournament_repository.dart';

class PlayerTournamentsNotifier extends StateNotifier<List<Tournament>> {
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;

  PlayerTournamentsNotifier() : super([]);

  Future<void> fetchTournaments({int limit = 5, required playerId}) async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    final result = await TournamentRepository.fetchPlayerTournaments(
      playerId: playerId,
      limit: limit,
      startAfter: _lastDocument,
    );

    final newTournaments = await Future.wait(result['tournaments'] as List<Future<Tournament>>);
    _lastDocument = result['lastDocument'] as DocumentSnapshot?;

    if (newTournaments.isNotEmpty) {
      state = [...state, ...newTournaments];
    } else {
      _hasMore = false;
    }
    _isLoading = false;
  }
}

final playerTournamentsProvider =
    StateNotifierProvider<PlayerTournamentsNotifier, List<Tournament>>(
        (ref) => PlayerTournamentsNotifier());
