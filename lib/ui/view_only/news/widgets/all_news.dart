import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/view_only/news/view_models/news_cubit.dart';
import 'package:tennis_cup/ui/view_only/news/widgets/single_news.dart';

class AllNews extends StatelessWidget {
  const AllNews({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Flexible(
      fit: FlexFit.loose,
      child: BlocBuilder<NewsCubit, NewsState>(
        builder: (context, state) {
          if (state is NewsError) {
            return Text(s.oopsSomethingWentWrong);
          }

          if (state is NewsFetched && state.fetchedNews.isEmpty) {
            return Text(s.noNewsFound);
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
