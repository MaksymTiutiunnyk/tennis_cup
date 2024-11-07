import 'package:flutter/material.dart';
import 'package:tennis_cup/data/news.dart';
import 'package:tennis_cup/widgets/news_widgets/single_interesting_news.dart';

class InterestingNews extends StatelessWidget {
  const InterestingNews({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        controller: PageController(viewportFraction: 0.90),
        itemCount: news.where((element) => element.isInteresting).length,
        itemBuilder: (context, index) {
          if (news[index].isInteresting) {
            return SingleInterestingNews(news: news[index]);
          }
          return null;
        },
      ),
    );
  }
}
