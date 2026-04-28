import 'package:dio/dio.dart';
import 'package:tennis_cup/data/services/abstract/i_arena_service.dart';
import 'package:tennis_cup/data/services/dto/arena_dto.dart';

class RestArenaService implements IArenaService {
  final Dio _dio;

  const RestArenaService(this._dio);

  @override
  Future<List<ArenaDto>> fetchAllArenas() async {
    final response = await _dio.get('/api/v1/arenas');
    final data = response.data as List<dynamic>;
    return data
        .map((json) => ArenaDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
