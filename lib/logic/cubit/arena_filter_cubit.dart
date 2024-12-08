import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/arena.dart';

class ArenaFilterCubit extends Cubit<Arena> {
  ArenaFilterCubit(super.initialArena);

  void selectArena(Arena arena) {
    emit(arena);
  }
}
