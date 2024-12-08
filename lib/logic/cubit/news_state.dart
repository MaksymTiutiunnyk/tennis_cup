part of 'news_cubit.dart';

class NewsState {
  const NewsState();
}

class NewsFetching extends NewsState {}

class NewsFetched extends NewsState {
  final List<News> fetchedNews;

  const NewsFetched({required this.fetchedNews});
}