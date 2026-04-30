import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/news.dart';
import 'package:tennis_cup/data/repositories/news_repository.dart';

part 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsRepository newsRepository;
  DateTime _selectedPeriod = DateTime.now();
  List<News>? _interestingNews;

  NewsCubit({required this.newsRepository})
      : super(NewsFetching(DateTime.now())) {
    fetchNews(_selectedPeriod);
    fetchInterestingNews();
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
      emit(NewsFetched(
        selectedPeriod: period,
        fetchedNews: fetchedNews,
        interestingNews: _interestingNews,
      ));
    } catch (e) {
      emit(NewsError(period, e));
    }
  }

  void fetchInterestingNews() async {
    try {
      _interestingNews = await newsRepository.fetchInterestingNews();
      final current = state;
      if (current is NewsFetched) {
        emit(NewsFetched(
          selectedPeriod: current.selectedPeriod,
          fetchedNews: current.fetchedNews,
          interestingNews: _interestingNews,
        ));
      }
      // if state is NewsFetching, _interestingNews will be picked up
      // when fetchNews completes
    } catch (_) {
      _interestingNews = const [];
    }
  }
}
