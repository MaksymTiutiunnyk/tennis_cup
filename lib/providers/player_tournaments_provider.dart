import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/repositories/tournament_repository.dart';

class PlayerTournamentsNotifier extends StateNotifier<Map<String, dynamic>> {
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;

  PlayerTournamentsNotifier() : super({'tournaments': [], 'isLoading': true});

  Future<void> fetchTournaments({int limit = 5, required playerId}) async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    if (!state['isLoading']) {
      state = {'tournaments': state['tournaments'], 'isLoading': _isLoading};
    }

    final result = await TournamentRepository.fetchPlayerTournaments(
      playerId: playerId,
      limit: limit,
      startAfter: _lastDocument,
    );

    final newTournaments =
        await Future.wait(result['tournaments'] as List<Future<Tournament>>);
    _lastDocument = result['lastDocument'] as DocumentSnapshot?;

    if (newTournaments.isNotEmpty) {
      state = {
        'tournaments': [...state['tournaments'], ...newTournaments],
        'isLoading': _isLoading
      };
    } else {
      _hasMore = false;
    }
    _isLoading = false;
    state = {'tournaments': state['tournaments'], 'isLoading': _isLoading};
  }
}

final playerTournamentsProvider =
    StateNotifierProvider<PlayerTournamentsNotifier, Map<String, dynamic>>(
        (ref) => PlayerTournamentsNotifier());
