import 'dart:convert';
import 'dart:io';

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

  @override
  Future<NewsDto> createNews({
    required String title,
    required String body,
    required DateTime newsTimestamp,
    required String importance,
    File? image,
  }) async {
    final formData = FormData();
    formData.files.add(MapEntry(
      'news',
      MultipartFile.fromString(
        jsonEncode({
          'title': title,
          'body': body,
          'newsTimestamp': newsTimestamp.toUtc().toIso8601String(),
          'importance': importance,
        }),
        contentType: DioMediaType('application', 'json'),
      ),
    ));
    if (image != null) {
      formData.files.add(MapEntry(
        'image',
        await MultipartFile.fromFile(
          image.path,
          contentType: _mediaType(image.path),
        ),
      ));
    }
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/news',
      data: formData,
    );
    return NewsDto.fromJson(response.data!);
  }

  @override
  Future<NewsDto> updateNews(
    int id, {
    String? title,
    String? body,
    DateTime? newsTimestamp,
    String? importance,
    bool removeImage = false,
    File? image,
  }) async {
    final formData = FormData();
    formData.files.add(MapEntry(
      'news',
      MultipartFile.fromString(
        jsonEncode({
          if (title != null) 'title': title,
          if (body != null) 'body': body,
          if (newsTimestamp != null)
            'newsTimestamp': newsTimestamp.toUtc().toIso8601String(),
          if (importance != null) 'importance': importance,
          'removeImage': removeImage,
        }),
        contentType: DioMediaType('application', 'json'),
      ),
    ));
    if (image != null) {
      formData.files.add(MapEntry(
        'image',
        await MultipartFile.fromFile(
          image.path,
          contentType: _mediaType(image.path),
        ),
      ));
    }
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/news/$id',
      data: formData,
    );
    return NewsDto.fromJson(response.data!);
  }

  @override
  Future<void> deleteNews(int id) async {
    await _dio.delete<void>('/api/v1/news/$id');
  }

  static List<NewsDto> _parseContent(Map<String, dynamic> data) {
    final content = data['content'] as List<dynamic>;
    return content
        .map((e) => NewsDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static DioMediaType _mediaType(String path) {
    final ext = path.toLowerCase().split('.').last;
    return switch (ext) {
      'png' => DioMediaType('image', 'png'),
      'webp' => DioMediaType('image', 'webp'),
      _ => DioMediaType('image', 'jpeg'),
    };
  }
}
