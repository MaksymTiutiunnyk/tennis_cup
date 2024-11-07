import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/data/news.dart';
import 'package:tennis_cup/model/news.dart';
import 'package:tennis_cup/providers/news_period_provider.dart';

final newsProvider = Provider<List<News>>((ref) {
  DateTime period = ref.watch(newsPeriodProvider);

  List<News> filteredNews = news
      .where((element) =>
          element.date.year == period.year &&
          element.date.month == period.month)
      .toList();

  return filteredNews;
});
