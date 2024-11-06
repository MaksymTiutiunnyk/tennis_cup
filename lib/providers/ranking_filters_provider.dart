import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/data/players.dart';
import 'package:tennis_cup/model/player.dart';

class RankingFiltersNotifier extends StateNotifier<Sex> {
  RankingFiltersNotifier() : super(Sex.All);

  void selectSex(Sex sex) {
    state = sex;
  }
}

final rankingFiltersProvider =
    StateNotifierProvider<RankingFiltersNotifier, Sex>(
        (ref) => RankingFiltersNotifier());

final filteredPlayersProvider = Provider((ref) {
  Sex sexToInclude = ref.watch(rankingFiltersProvider);
  List<Player> filteredPlayers;

  if (sexToInclude == Sex.All) {
    filteredPlayers = players;
  } else {
    filteredPlayers =
        players.where((player) => player.sex == sexToInclude).toList();
  }

  return filteredPlayers;
});
