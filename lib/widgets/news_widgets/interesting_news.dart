import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/news.dart';
import 'package:tennis_cup/providers/interesting_news_provider.dart';
import 'package:tennis_cup/widgets/news_widgets/single_interesting_news.dart';

class InterestingNews extends ConsumerWidget {
  const InterestingNews({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<News>> newsList = ref.watch(interestingNewsProvider);

    return Expanded(
      child: newsList.when(
        data: (newsList) {
          List<News> interestingNews =
              newsList.where((news) => news.isInteresting).toList();
          return PageView.builder(
            scrollDirection: Axis.horizontal,
            controller: PageController(viewportFraction: 0.90),
            itemCount: interestingNews.length,
            itemBuilder: (context, index) {
              return SingleInterestingNews(news: interestingNews[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          return Center(child: Text('Error: $error'));
        },
      ),
    );
  }
}
