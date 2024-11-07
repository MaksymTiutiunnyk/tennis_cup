import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/data/arenas.dart';
import 'package:tennis_cup/model/arena.dart';

class ArenaFilterNotifier extends StateNotifier<Arena> {
  ArenaFilterNotifier() : super(arenas[0]);

  void selectArena(Arena arena) {
    state = arena;
  }
}

final arenaFilterProvider = StateNotifierProvider<ArenaFilterNotifier, Arena>(
    (ref) => ArenaFilterNotifier());
