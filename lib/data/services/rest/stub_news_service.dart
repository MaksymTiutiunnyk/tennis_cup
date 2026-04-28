import 'package:tennis_cup/data/models/news.dart';
import 'package:tennis_cup/data/services/abstract/i_news_service.dart';

class StubNewsService implements INewsService {
  const StubNewsService();

  @override
  Future<List<News>> fetchNewsWithinPeriod(
          DateTime start, DateTime end) async =>
      [];

  @override
  Future<List<News>> fetchInterestingNews() async => [];
}
