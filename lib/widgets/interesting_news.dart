import 'package:flutter/material.dart';
import 'package:tennis_cup/data/news.dart';
import 'package:tennis_cup/widgets/single_interesting_news.dart';

class InterestingNews extends StatefulWidget {
  const InterestingNews({super.key});

  @override
  State<InterestingNews> createState() {
    return _InterestingNewsState();
  }
}

class _InterestingNewsState extends State<InterestingNews> {
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
        },
      ),
    );
  }
}
