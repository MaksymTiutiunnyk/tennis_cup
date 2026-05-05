import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/ui/view_only/news/view_models/news_cubit.dart';
import 'package:tennis_cup/ui/view_only/news/widgets/single_interesting_news.dart';

class InterestingNews extends StatelessWidget {
  const InterestingNews({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isScreenHigh = height / width > 16 / 9;

    return SizedBox(
      height: isScreenHigh ? height * 0.4 : height * 0.5,
      child: BlocBuilder<NewsCubit, NewsState>(
        buildWhen: (previous, current) {
          if (previous is NewsFetched && current is NewsFetched) {
            return !listEquals(
              previous.interestingNews,
              current.interestingNews,
            );
          }
          return true;
        },
        builder: (context, state) {
          if (state is NewsFetching) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NewsFetched) {
            final interesting = state.interestingNews;
            if (interesting.isEmpty) {
              return const Center(child: Text('No interesting news found'));
            }
            return PageView.builder(
              scrollDirection: Axis.horizontal,
              controller: PageController(viewportFraction: 0.90),
              itemCount: interesting.length,
              itemBuilder: (context, index) => SingleInterestingNews(
                news: interesting[index],
                isScreenWide: width > 600,
              ),
            );
          }
          return const Center(child: Text('Ooops, something went wrong'));
        },
      ),
    );
  }
}
