import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/data_providers/news_api.dart';
import 'package:tennis_cup/data/models/news.dart';
import 'package:tennis_cup/data/repositories/news_repository.dart';
import 'package:tennis_cup/logic/cubit/news_period_cubit.dart';

part 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final newsRepository = const NewsRepository(newsApi: NewsApi());
  final NewsPeriodCubit newsPeriodCubit;
  late StreamSubscription newsPeriodSubscription;

  NewsCubit({required this.newsPeriodCubit}) : super(NewsFetching()) {
    newsPeriodSubscription = newsPeriodCubit.stream.listen((period) {
      fetchNews(period);
    });
  }

  void fetchNews(DateTime period) async {
    emit(NewsFetching());

    final fetchedNews = await newsRepository.fetchNewsWithinPeriod(period);

    emit(NewsFetched(fetchedNews: fetchedNews));
  }

  @override
  Future<void> close() {
    newsPeriodSubscription.cancel();
    return super.close();
  }
}
