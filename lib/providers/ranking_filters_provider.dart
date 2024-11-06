import 'package:flutter_riverpod/flutter_riverpod.dart';
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
