import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/services/abstract/i_news_service.dart';
import 'package:tennis_cup/data/services/dto/news_dto.dart';

final _dateFmt = DateFormat('yyyy-MM-dd');

class RestNewsService implements INewsService {
  final Dio _dio;

  const RestNewsService(this._dio);

  @override
  Future<List<NewsDto>> fetchNewsWithinPeriod(
      DateTime start, DateTime end) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/news',
      queryParameters: {
        'dateFrom': _dateFmt.format(start),
        'dateTo': _dateFmt.format(end.subtract(const Duration(days: 1))),
        'size': 100,
      },
    );
    return _parseContent(response.data!);
  }

  @override
  Future<List<NewsDto>> fetchInterestingNews() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/news',
      queryParameters: {
        'importance': 'INTERESTING',
        'size': 20,
      },
    );
    return _parseContent(response.data!);
  }

  static List<NewsDto> _parseContent(Map<String, dynamic> data) {
    final content = data['content'] as List<dynamic>;
    return content
        .map((e) => NewsDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
