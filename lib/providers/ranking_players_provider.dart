import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/providers/sex_filter_provider.dart';
import 'package:tennis_cup/repositories/player_repository.dart';
import 'package:tennis_cup/model/player.dart';

class RankingPlayersNotifier extends StateNotifier<Map<String, dynamic>> {
  final Sex sexFilter;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;

  RankingPlayersNotifier(this.sexFilter)
      : super({'players': [], 'isLoading': false});

  Future<void> fetchPlayers({int limit = 5}) async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    state = {'players': state['players'], 'isLoading': _isLoading};
    final result = await PlayerRepository.fetchRankingPlayers(
      limit: limit,
      startAfter: _lastDocument,
      sexFilter: sexFilter,
    );

    final newPlayers = result['players'] as List<Player>;
    _lastDocument = result['lastDocument'] as DocumentSnapshot?;

    if (newPlayers.isNotEmpty) {
      state = {
        'players': [...state['players'], ...newPlayers],
        'isLoading': _isLoading
      };
    } else {
      _hasMore = false;
    }
    _isLoading = false;
    state = {'players': state['players'], 'isLoading': _isLoading};
  }
}

final rankingPlayersProvider =
    StateNotifierProvider<RankingPlayersNotifier, Map<String, dynamic>>((ref) {
  final sexFilter = ref.watch(sexFilterProvider);

  final notifier = RankingPlayersNotifier(sexFilter);
  notifier.fetchPlayers();
  return notifier;
});
