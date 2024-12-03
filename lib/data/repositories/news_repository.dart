import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/data/data_providers/news_api.dart';
import 'package:tennis_cup/data/models/news.dart';

class NewsRepository {
  final NewsApi newsApi;

  const NewsRepository({required this.newsApi});

  Future<List<News>> fetchNewsWithinPeriod(DateTime period) async {
    final querySnapshot = await newsApi.fetchNewsWithinPeriod(period);

    List<News> newsList = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return News(
          title: data['title'] == "" ? 'Attention!' : data['title'],
          text: data['text'],
          date: (data['date'] as Timestamp).toDate(),
          imageUrl: data['imageUrl']);
    }).toList();

    return newsList;
  }

   Future<List<News>> fetchInterestingNews() async {
    final querySnapshot = await newsApi.fetchInterestingNews();

    List<News> interestingNews = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return News(
        title: data['title'] == "" ? 'Attention!' : data['title'],
        text: data['text'],
        date: (data['date'] as Timestamp).toDate(),
        imageUrl: data['imageUrl'],
      );
    }).toList();

    return interestingNews;
  }
}
