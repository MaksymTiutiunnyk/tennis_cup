import 'package:flutter/material.dart';
import 'package:tennis_cup/data/data_providers/news_api.dart';
import 'package:tennis_cup/data/repositories/news_repository.dart';
import 'package:tennis_cup/presentation/widgets/news_widgets/single_interesting_news.dart';

class InterestingNews extends StatelessWidget {
  final newsRepository = const NewsRepository(newsApi: NewsApi());
  const InterestingNews({super.key});

  @override
  Widget build(BuildContext context) {
    final interestingNews = newsRepository.fetchInterestingNews();

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isScreenHigh = height / width > 16 / 9;

    return SizedBox(
      height: isScreenHigh ? height * 0.4 : height * 0.5,
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
                return SingleInterestingNews(
                  news: snapshot.data![index],
                  isScreenWide: width > 600,
                );
              },
            );
          }
          return const Center(child: Text('Ooops, something went wrong'));
        },
      ),
    );
  }
}
