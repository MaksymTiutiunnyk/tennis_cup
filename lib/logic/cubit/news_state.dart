part of 'news_cubit.dart';

class NewsState {}

class NewsFetching extends NewsState {}

class NewsFetched extends NewsState {
  final List<News> fetchedNews;

  NewsFetched({required this.fetchedNews});
}