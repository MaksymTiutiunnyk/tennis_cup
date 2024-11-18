import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/player.dart';

class SexFilterNotifier extends StateNotifier<Sex> {
  SexFilterNotifier() : super(Sex.All);

  void selectSex(Sex sex) {
    state = sex;
  }
}

final sexFilterProvider =
    StateNotifierProvider<SexFilterNotifier, Sex>((ref) => SexFilterNotifier());
