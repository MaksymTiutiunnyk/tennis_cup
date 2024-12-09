import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/logic/cubit/news_cubit.dart';
import 'package:tennis_cup/logic/cubit/news_period_cubit.dart';
import 'package:tennis_cup/presentation/widgets/news_widgets/single_news.dart';

class AllNews extends StatefulWidget {
  const AllNews({super.key});

  @override
  State<AllNews> createState() => _AllNewsState();
}

class _AllNewsState extends State<AllNews> {
  @override
  void initState() {
    super.initState();
    context.read<NewsCubit>().fetchNews(context.read<NewsPeriodCubit>().state);
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: BlocBuilder<NewsCubit, NewsState>(
        builder: (context, state) {
          if (state is NewsFetched && state.fetchedNews.isEmpty) {
            return const Text('No news found');
          }

          if (state is NewsFetched) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.fetchedNews.length,
              itemBuilder: (ctx, index) {
                return SingleNews(news: state.fetchedNews[index]);
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
