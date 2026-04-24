import 'package:tennis_cup/data/models/news.dart';

abstract interface class INewsService {
  Future<List<News>> fetchNewsWithinPeriod(DateTime period);
  Future<List<News>> fetchInterestingNews();
}
