import 'package:tennis_cup/data/services/dto/news_dto.dart';

abstract interface class INewsService {
  Future<List<NewsDto>> fetchNewsWithinPeriod(DateTime start, DateTime end);
  Future<List<NewsDto>> fetchInterestingNews();
}
