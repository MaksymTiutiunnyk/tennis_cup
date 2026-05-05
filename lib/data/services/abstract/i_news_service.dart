import 'dart:io';

import 'package:tennis_cup/data/services/dto/news_dto.dart';

abstract interface class INewsService {
  Future<List<NewsDto>> fetchNewsWithinPeriod(DateTime start, DateTime end);
  Future<List<NewsDto>> fetchInterestingNews();
  Future<NewsDto> createNews({
    required String title,
    required String body,
    required DateTime newsTimestamp,
    required String importance,
    File? image,
  });
  Future<NewsDto> updateNews(
    int id, {
    String? title,
    String? body,
    DateTime? newsTimestamp,
    String? importance,
    bool removeImage,
    File? image,
  });
  Future<void> deleteNews(int id);
}
