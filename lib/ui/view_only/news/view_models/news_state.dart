part of 'news_cubit.dart';

abstract class NewsState {
  final DateTime selectedPeriod;
  const NewsState(this.selectedPeriod);
}

class NewsFetching extends NewsState {
  const NewsFetching(super.selectedPeriod);
}

class NewsFetched extends NewsState {
  final List<News> fetchedNews;

  const NewsFetched({
    required DateTime selectedPeriod,
    required this.fetchedNews,
  }) : super(selectedPeriod);

  List<News> get interestingNews =>
      fetchedNews.where((n) => n.isInteresting).toList();
}

class NewsError extends NewsState {
  final Object e;
  const NewsError(super.selectedPeriod, this.e);
}
