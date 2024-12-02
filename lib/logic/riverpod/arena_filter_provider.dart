import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/data/data_providers/arenas.dart';
import 'package:tennis_cup/data/models/arena.dart';

class ArenaFilterNotifier extends StateNotifier<Arena> {
  ArenaFilterNotifier() : super(arenas[1]);

  void selectArena(Arena arena) {
    state = arena;
  }
}

final arenaFilterProvider = StateNotifierProvider<ArenaFilterNotifier, Arena>(
    (ref) => ArenaFilterNotifier());
