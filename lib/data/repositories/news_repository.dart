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

  static News _toNews(NewsDto dto) => News(
        id: dto.id,
        title: dto.title,
        text: dto.body,
        date: dto.newsTimestamp,
        isInteresting: dto.importance == 'INTERESTING',
        imageUrl: dto.imageUrl ?? '',
      );
}
