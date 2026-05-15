import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/repositories/arena_repository.dart';

sealed class ArenasState {}

final class ArenasLoading extends ArenasState {}

final class ArenasLoaded extends ArenasState {
  final List<Arena> arenas;
  ArenasLoaded(this.arenas);
}

final class ArenasError extends ArenasState {}

class ArenasCubit extends Cubit<ArenasState> {
  final ArenaRepository arenaRepository;

  ArenasCubit({required this.arenaRepository}) : super(ArenasLoading()) {
    _fetch();
  }

  void _fetch() async {
    try {
      final arenas = await arenaRepository.fetchAllArenas();
      if (isClosed) return;
      emit(ArenasLoaded(arenas));
    } catch (_) {
      if (isClosed) return;
      emit(ArenasError());
    }
  }
}
