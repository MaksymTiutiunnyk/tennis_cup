import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/logic/cubit/news_cubit.dart';
import 'package:tennis_cup/presentation/widgets/news_widgets/single_interesting_news.dart';

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
            return previous.interestingNews != current.interestingNews;
          }
          return true;
        },
        builder: (context, state) {
          if (state is NewsFetching || (state is NewsFetched && state.interestingNews == null)) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NewsFetched) {
            if (state.interestingNews!.isEmpty) {
              return const Center(child: Text('No interesting news found'));
            }
            return PageView.builder(
              scrollDirection: Axis.horizontal,
              controller: PageController(viewportFraction: 0.90),
              itemCount: state.interestingNews!.length,
              itemBuilder: (context, index) {
                return SingleInterestingNews(
                  news: state.interestingNews![index],
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
