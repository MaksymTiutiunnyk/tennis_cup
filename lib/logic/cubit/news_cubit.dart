import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/news.dart';
import 'package:tennis_cup/data/repositories/news_repository.dart';
import 'package:tennis_cup/logic/cubit/news_period_cubit.dart';

part 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsRepository newsRepository;
  final NewsPeriodCubit newsPeriodCubit;
  late StreamSubscription newsPeriodSubscription;

  NewsCubit({
    required this.newsRepository,
    required this.newsPeriodCubit,
  }) : super(NewsFetching()) {
    newsPeriodSubscription = newsPeriodCubit.stream.listen((period) {
      fetchNews(period);
    });
  }

  void fetchNews(DateTime period) async {
    emit(NewsFetching());

    try {
      final fetchedNews = await newsRepository.fetchNewsWithinPeriod(
          DateTime(period.year, period.month),
          DateTime(period.year, period.month + 1));
      emit(NewsFetched(fetchedNews: fetchedNews));
    } catch (e) {
      emit(NewsError(e));
    }
  }

  @override
  Future<void> close() {
    newsPeriodSubscription.cancel();
    return super.close();
  }
}
