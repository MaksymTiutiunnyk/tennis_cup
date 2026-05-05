import 'dart:io';

import 'package:tennis_cup/data/models/news.dart';
import 'package:tennis_cup/data/services/abstract/i_news_service.dart';
import 'package:tennis_cup/data/services/dto/news_dto.dart';

class NewsRepository {
  final INewsService _service;

  const NewsRepository(this._service);

  Future<List<News>> fetchNewsWithinPeriod(DateTime start, DateTime end) async {
    final dtos = await _service.fetchNewsWithinPeriod(start, end);
    return dtos.map(_toNews).toList();
  }

  Future<List<News>> fetchInterestingNews() async {
    final dtos = await _service.fetchInterestingNews();
    return dtos.map(_toNews).toList();
  }

  Future<News> createNews({
    required String title,
    required String body,
    required DateTime newsTimestamp,
    required String importance,
    File? image,
  }) async {
    final dto = await _service.createNews(
      title: title,
      body: body,
      newsTimestamp: newsTimestamp,
      importance: importance,
      image: image,
    );
    return _toNews(dto);
  }

  Future<News> updateNews(
    int id, {
    String? title,
    String? body,
    DateTime? newsTimestamp,
    String? importance,
    bool removeImage = false,
    File? image,
  }) async {
    final dto = await _service.updateNews(
      id,
      title: title,
      body: body,
      newsTimestamp: newsTimestamp,
      importance: importance,
      removeImage: removeImage,
      image: image,
    );
    return _toNews(dto);
  }

  Future<void> deleteNews(int id) => _service.deleteNews(id);

  static News _toNews(NewsDto dto) => News(
        id: dto.id,
        title: dto.title,
        text: dto.body,
        date: dto.newsTimestamp,
        isInteresting: dto.importance == 'INTERESTING',
        imageUrl: dto.imageUrl ?? '',
      );
}
