import 'package:dio/dio.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/services/abstract/i_arena_service.dart';

class RestArenaService implements IArenaService {
  final Dio _dio;

  const RestArenaService(this._dio);

  @override
  Future<List<Arena>> fetchAllArenas() async {
    final response = await _dio.get('/api/v1/arenas');
    final data = response.data as List<dynamic>;
    return data
        .map((json) => Arena.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
