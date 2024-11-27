import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/news.dart';
import 'package:tennis_cup/providers/news_provider.dart';
import 'package:tennis_cup/widgets/news_widgets/single_news.dart';

class AllNews extends ConsumerWidget {
  const AllNews({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<News>> newsList = ref.watch(newsProvider);

    return Flexible(
      fit: FlexFit.loose,
      child: newsList.when(
        data: (newsList) {
          if (newsList.isEmpty) {
            return const Text('No news found');
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: newsList.length,
            itemBuilder: (ctx, index) {
              return SingleNews(news: newsList[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Text('Ooops, something went wrong'),
      ),
    );
  }
}
