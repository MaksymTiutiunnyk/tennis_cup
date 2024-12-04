import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/data_providers/arenas.dart';
import 'package:tennis_cup/data/models/arena.dart';

class ArenaFilterCubit extends Cubit<Arena> {
  ArenaFilterCubit() : super(arenas[1]);

  void selectArena(Arena arena) {
    emit(arena);
  }
}
