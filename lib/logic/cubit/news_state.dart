part of 'news_cubit.dart';

abstract class NewsState {
  const NewsState();
}

class NewsFetching extends NewsState {}

class NewsFetched extends NewsState {
  final List<News> fetchedNews;

  const NewsFetched({required this.fetchedNews});
}

class NewsError extends NewsState {
  final Object e;

  const NewsError(this.e);
}