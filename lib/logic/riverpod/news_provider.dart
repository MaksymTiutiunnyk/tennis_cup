import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/data/models/news.dart';
import 'package:tennis_cup/logic/riverpod/news_period_provider.dart';
import 'package:tennis_cup/data/repositories/news_repository.dart';

final newsProvider = FutureProvider<List<News>>((ref) async {
  DateTime period = ref.watch(newsPeriodProvider);

  return await NewsRepository.fetchNewsWithinPeriod(period);
});
