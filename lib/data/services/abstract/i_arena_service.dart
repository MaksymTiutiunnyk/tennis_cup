import 'package:tennis_cup/data/models/arena.dart';

abstract interface class IArenaService {
  Future<List<Arena>> fetchAllArenas();
}
