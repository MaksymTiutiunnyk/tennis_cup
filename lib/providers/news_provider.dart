import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/news.dart';
import 'package:tennis_cup/providers/news_period_provider.dart';
import 'package:tennis_cup/repositories/news_repository.dart';

final newsProvider = FutureProvider<List<News>>((ref) async {
  DateTime period = ref.watch(newsPeriodProvider);

  return await NewsRepository.fetchNewsWithinPeriod(period);
});
