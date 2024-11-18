import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/model/news.dart';

class NewsRepository {
  static Future<List<News>> fetchNewsWithinPeriod(DateTime period) async {
    final newsCollection = FirebaseFirestore.instance.collection('news');

    QuerySnapshot querySnapshot = await newsCollection
        .where('date',
            isGreaterThanOrEqualTo: DateTime(period.year, period.month, 1))
        .where('date', isLessThan: DateTime(period.year, period.month + 1, 1))
        .orderBy('date', descending: true)
        .get();

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

  static Future<List<News>> fetchInterestingNews() async {
    final newsCollection = FirebaseFirestore.instance.collection('news');

    QuerySnapshot querySnapshot = await newsCollection
        .where('title', isNotEqualTo: 'Attention!')
        .limit(10)
        .get();

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
