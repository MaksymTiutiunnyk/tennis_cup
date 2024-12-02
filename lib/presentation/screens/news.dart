import 'package:flutter/material.dart';
import 'package:tennis_cup/presentation/widgets/news_widgets/all_news.dart';
import 'package:tennis_cup/presentation/widgets/news_widgets/interesting_news.dart';
import 'package:tennis_cup/presentation/widgets/news_widgets/period_section.dart';

class News extends StatelessWidget {
  const News({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InterestingNews(),
          PeriodSection(),
          AllNews(),
        ],
      ),
    );
  }
}
