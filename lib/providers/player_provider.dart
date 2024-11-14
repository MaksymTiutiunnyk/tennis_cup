import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/providers/sex_filter_provider.dart';
import 'package:tennis_cup/repositories/player_repository.dart';
import 'package:tennis_cup/model/player.dart';

class PlayerNotifier extends StateNotifier<List<Player>> {
  final PlayerRepository _repository;
  final Sex sexFilter;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;

  PlayerNotifier(this._repository, this.sexFilter) : super([]);

  Future<void> fetchPlayers({int limit = 10}) async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    final result = await _repository.fetchPlayers(
      limit: limit,
      startAfter: _lastDocument,
      sexFilter: sexFilter,
    );

    final newPlayers = result['players'] as List<Player>;
    _lastDocument = result['lastDocument'] as DocumentSnapshot?;

    if (newPlayers.isNotEmpty) {
      state = [...state, ...newPlayers];
    } else {
      _hasMore = false;
    }
    _isLoading = false;
  }
}

final playerRepositoryProvider = Provider((ref) => PlayerRepository());

final playerNotifierProvider = StateNotifierProvider<PlayerNotifier, List<Player>>((ref) {
  final repository = ref.watch(playerRepositoryProvider);
  final sexFilter = ref.watch(sexFilterProvider);
  return PlayerNotifier(repository, sexFilter);
});