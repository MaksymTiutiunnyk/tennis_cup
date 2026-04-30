import 'package:tennis_cup/data/models/news.dart';
import 'package:tennis_cup/data/services/abstract/i_news_service.dart';

class NewsRepository {
  final INewsService _service;

  const NewsRepository(this._service);

  Future<List<News>> fetchNewsWithinPeriod(DateTime start, DateTime end) {
    return _service.fetchNewsWithinPeriod(start, end);
  }

  Future<List<News>> fetchInterestingNews() {
    return _service.fetchInterestingNews();
  }
}
