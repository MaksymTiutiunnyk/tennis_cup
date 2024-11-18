import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/news.dart';
import 'package:tennis_cup/repositories/news_repository.dart';

final interestingNewsProvider = FutureProvider<List<News>>((ref) async {
  return await NewsRepository.fetchInterestingNews();
});
