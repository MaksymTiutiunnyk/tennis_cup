import 'package:tennis_cup/data/services/dto/arena_dto.dart';

abstract interface class IArenaService {
  Future<List<ArenaDto>> fetchAllArenas();
}
