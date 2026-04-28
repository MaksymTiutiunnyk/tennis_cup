import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/services/abstract/i_arena_service.dart';
import 'package:tennis_cup/data/services/dto/arena_dto.dart';

class ArenaRepository {
  final IArenaService _service;

  const ArenaRepository(this._service);

  Future<List<Arena>> fetchAllArenas() async {
    final dtos = await _service.fetchAllArenas();
    return dtos.map(_toArena).toList();
  }

  static Arena _toArena(ArenaDto dto) => Arena(
        id: dto.id.toString(),
        title: dto.name,
        color: arenaColorFromString(dto.color),
        city: dto.city,
      );
}
