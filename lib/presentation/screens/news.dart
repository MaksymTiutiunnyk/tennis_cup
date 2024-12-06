import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/logic/cubit/news_cubit.dart';
import 'package:tennis_cup/logic/cubit/news_period_cubit.dart';
import 'package:tennis_cup/presentation/widgets/news_widgets/all_news.dart';
import 'package:tennis_cup/presentation/widgets/news_widgets/interesting_news.dart';
import 'package:tennis_cup/presentation/widgets/news_widgets/period_section.dart';

class News extends StatelessWidget {
  const News({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NewsCubit(
        newsPeriodCubit: BlocProvider.of<NewsPeriodCubit>(context),
      ),
      child: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InterestingNews(),
            PeriodSection(),
            AllNews(),
          ],
        ),
      ),
    );
  }
}
