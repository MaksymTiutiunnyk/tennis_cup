import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/repositories/tournament_repository.dart';

class PlayersTournamentsNotifier extends StreamNotifier<List<Tournament>> {
  bool _isLoading = false;

  final String player1Id;
  final String player2Id;

  PlayersTournamentsNotifier(
      {required this.player1Id, required this.player2Id});

  Future<void> fetchTournaments({
    int limit = 5,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    state = const AsyncValue.loading();

    final result = await TournamentRepository.fetchPlayersTournaments(
      player1Id: player1Id,
      player2Id: player2Id,
      limit: limit,
    );

    final tournaments = result['tournaments'] as List<Tournament>;

    state = AsyncValue.data(tournaments);
    _isLoading = false;
  }

  void reset() {
    state = const AsyncValue.data([]);
    _isLoading = false;
  }

  @override
  Stream<List<Tournament>> build() async* {
    await fetchTournaments();
    yield state.value!;

    final tournamentIds = state.value!.map((e) => e.tournamentId).toList();

    await for (final _
        in TournamentRepository.watchMatchChanges(tournamentIds)) {
      await fetchTournaments();
      yield state.value!;
    }
  }
}

// final playersTournamentsProvider =
//     StreamNotifierProvider<PlayersTournamentsNotifier, List<Tournament>>(
//          () => PlayersTournamentsNotifier.new(player1Id: ));
