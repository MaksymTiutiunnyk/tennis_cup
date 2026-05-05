import 'package:flutter/material.dart';
import 'package:tennis_cup/ui/view_only/news/widgets/all_news.dart';
import 'package:tennis_cup/ui/view_only/news/widgets/interesting_news.dart';
import 'package:tennis_cup/ui/view_only/news/widgets/period_section.dart';

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
