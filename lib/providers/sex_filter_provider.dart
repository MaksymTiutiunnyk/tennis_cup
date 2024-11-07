import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/data/players.dart';
import 'package:tennis_cup/model/player.dart';

class SexFilterNotifier extends StateNotifier<Sex> {
  SexFilterNotifier() : super(Sex.All);

  void selectSex(Sex sex) {
    state = sex;
  }
}

final rankingFiltersProvider =
    StateNotifierProvider<SexFilterNotifier, Sex>(
        (ref) => SexFilterNotifier());

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
