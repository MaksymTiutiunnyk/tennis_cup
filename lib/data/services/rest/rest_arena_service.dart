import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
        .map((json) => _arenaFromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Arena _arenaFromJson(Map<String, dynamic> json) {
    return Arena(
      id: json['id']?.toString(),
      title: json['name'] as String,
      color: _colorFromString(json['color'] as String? ?? ''),
      city: json['city'] as String?,
    );
  }

  static Color _colorFromString(String value) {
    switch (value.toUpperCase()) {
      case 'RED':    return Colors.red;
      case 'GREEN':  return Colors.green;
      case 'BLUE':   return Colors.blue;
      case 'YELLOW': return Colors.yellow;
      case 'WHITE':  return Colors.white;
      case 'BLACK':  return Colors.black;
      case 'BROWN':  return Colors.brown;
      default:       return Colors.grey;
    }
  }
}
