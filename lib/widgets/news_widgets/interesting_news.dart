import 'package:flutter/material.dart';
import 'package:tennis_cup/repositories/news_repository.dart';
import 'package:tennis_cup/widgets/news_widgets/single_interesting_news.dart';

class InterestingNews extends StatelessWidget {
  const InterestingNews({super.key});

  @override
  Widget build(BuildContext context) {
    final interestingNews = NewsRepository.fetchInterestingNews();

    return Expanded(
      child: FutureBuilder(
        future: interestingNews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Center(child: Text('No interesting news found'));
            }
            return PageView.builder(
              scrollDirection: Axis.horizontal,
              controller: PageController(viewportFraction: 0.90),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return SingleInterestingNews(news: snapshot.data![index]);
              },
            );
          }
          return const Center(child: Text('Ooops, something went wrong'));
        },
      ),
    );
  }
}
