import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/utils/error_utils.dart';
import 'package:tennis_cup/data/models/news.dart';
import 'package:tennis_cup/data/repositories/news_repository.dart';

part 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsRepository newsRepository;
  DateTime _selectedPeriod = DateTime.now();

  NewsCubit({required this.newsRepository})
      : super(NewsFetching(DateTime.now())) {
    fetchNews(_selectedPeriod);
  }

  void selectPeriod(DateTime period) {
    _selectedPeriod = period;
    fetchNews(period);
  }

  void fetchNews(DateTime period) async {
    emit(NewsFetching(period));
    try {
      final fetchedNews = await newsRepository.fetchNewsWithinPeriod(
        DateTime(period.year, period.month),
        DateTime(period.year, period.month + 1),
      );
      if (isClosed) return;
      emit(NewsFetched(selectedPeriod: period, fetchedNews: fetchedNews));
    } catch (e) {
      if (isClosed) return;
      emit(NewsError(period, errorMessage(e)));
    }
  }
}
