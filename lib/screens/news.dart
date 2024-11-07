import 'package:flutter/material.dart';
import 'package:tennis_cup/widgets/news_widgets/all_news.dart';
import 'package:tennis_cup/widgets/news_widgets/interesting_news.dart';

class News extends StatelessWidget {
  const News({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        InterestingNews(),
        AllNews(),
      ],
    );
  }
}
