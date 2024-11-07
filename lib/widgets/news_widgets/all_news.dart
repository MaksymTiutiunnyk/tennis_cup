import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/model/news.dart';
import 'package:tennis_cup/providers/news_period_provider.dart';
import 'package:tennis_cup/providers/news_provider.dart';
import 'package:tennis_cup/widgets/news_widgets/single_news.dart';

DateFormat formatter = DateFormat('MMMM yyyy');

class AllNews extends ConsumerWidget {
  const AllNews({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime period = ref.watch(newsPeriodProvider);
    List<News> filteredNews = ref.watch(newsProvider);
    String formattedPeriod = formatter.format(period);

    return Expanded(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(0, 8, 0, 2),
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(width: 0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: period.year == 2018 && period.month == 1
                      ? null
                      : () {
                          ref.read(newsPeriodProvider.notifier).selectPeriod(
                              DateTime(
                                  period.year, period.month - 1, period.day));
                        },
                  icon: const Icon(Icons.arrow_back_ios),
                ),
                Text(formattedPeriod),
                IconButton(
                  onPressed: period.year == DateTime.now().year &&
                          period.month == DateTime.now().month
                      ? null
                      : () {
                          ref.read(newsPeriodProvider.notifier).selectPeriod(
                              DateTime(
                                  period.year, period.month + 1, period.day));
                        },
                  icon: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredNews.length,
              itemBuilder: (ctx, index) {
                return SingleNews(news: filteredNews[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
