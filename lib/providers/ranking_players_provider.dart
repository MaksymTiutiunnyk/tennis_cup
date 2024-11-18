import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/providers/sex_filter_provider.dart';
import 'package:tennis_cup/repositories/player_repository.dart';
import 'package:tennis_cup/model/player.dart';

class RankingPlayersNotifier extends StateNotifier<List<Player>> {
  final Sex sexFilter;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;

  RankingPlayersNotifier(this.sexFilter) : super([]);

  Future<void> fetchPlayers({int limit = 5}) async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    final result = await PlayerRepository.fetchPlayers(
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

final rankingPlayersProvider = StateNotifierProvider<RankingPlayersNotifier, List<Player>>((ref) {
  final sexFilter = ref.watch(sexFilterProvider);
  
  final notifier = RankingPlayersNotifier(sexFilter);
  notifier.fetchPlayers();
  return notifier;
});