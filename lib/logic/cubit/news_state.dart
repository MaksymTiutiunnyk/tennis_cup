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
  final List<News>? interestingNews; // null = still loading independently

  const NewsFetched({
    required DateTime selectedPeriod,
    required this.fetchedNews,
    this.interestingNews,
  }) : super(selectedPeriod);
}

class NewsError extends NewsState {
  final Object e;
  const NewsError(super.selectedPeriod, this.e);
}
