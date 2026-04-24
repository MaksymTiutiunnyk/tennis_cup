import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/services/abstract/i_arena_service.dart';

class ArenaRepository {
  final IArenaService _service;

  const ArenaRepository(this._service);

  Future<List<Arena>> fetchAllArenas() {
    return _service.fetchAllArenas();
  }
}
